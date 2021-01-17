--[[--
 Contains callbacks for general use and specific functions that constitute its
 API.

 @module engine
]]

local config
pcall(function () config = require "config" end)

local entityTagger = require "engine.tagger"
local systems = require "engine.systems"
local command = require "engine.command"
local handlers = require "engine.handlers"


local M = {}


local function load()
  local world = systems.load(love, entityTagger, command, config)
  
  for k, v in pairs(world) do
    M[k] = v
  end

  handlers.load(M)

  if not config then
    -- TODO: hello world
  end
end

local function update(dt)
  systems.update(dt, M.hid, M.gameState.components, M.collectableEffects,
                 M.resources, M.physics)
end

local function draw()
  systems.draw(M.gameState.components, M.gameState.inMenu, M.resources,
               M.release)
end


--[[--
 API

 Engine-specific functions

 @section api
]]

--[[--
 Hide menu and load a specific level of the game.

 Used often without arguments inside a @{setMenuOptionEffect} callback when a
 menu entity that has a `"Start Game"` option, or similar, is defined in
 `config.lua`.

 @tparam[opt=config.firstLevel] string level
  Name of the level, as defined in `config.lua`.
 @usage
  -- In this case, "Start Game" is the option number 1 of the menu
  engine.setMenuOptionEffect("mainMenu", 1, function ()
    engine.startGame()
  end)
]]
function M.startGame(level)
  M.gameState = systems.reload(level, M.gameState.inMenu)
end


--[[--
 Associate a callback to an option of a menu.
 @tparam string entity
  The identifier of the menu, as defined in `config.lua`
 @tparam number index Number of option in the `options` table of the menu
  that is defined in `config.lua`
 @tparam function callback What the option does when selected
 @usage
  engine.setMenuOptionEffect("mainMenu", 2, function ()
    print("Selected option 2!")
  end)
]]
function M.setMenuOptionEffect(entity, index, callback)
  local menu = M.gameState.components.menu
  if menu then
    menu[entityTagger.getId(entity)].callbacks[index] = callback
  end
end


--[[--
 Associate a callback to a collectable.
 @tparam string entity
  The identifier of the collectable, as defined in `config.lua`
 @tparam function callback What the collectable does when collected
 @usage
  engine.setCollectableEffect("healthPotion", function ()
    health = health + 1  -- defined in outer scope
  end)
]]
function M.setCollectableEffect(entity, callback)
  M.collectableEffects[entity] = callback
end


--[[--
  Create a new command.

  A command is a table that represents a keyboard or joystick gesture.

  See @{setInputs} for examples of use.

  @tparam table args Arguments for building the command. Valid arguments are:

  - **key:** String that represents a key, defined in the `keys` table in
    `config.lua`. If this argument is set, do not set the `keys` argument.
  - **keys:** Table of strings that represent keys, defined in the `keys`
    table in `config.lua`. If this argument is set, do not set the `key`
    argument.
  - **release:** `true` if the command represents an "up" gesture. `false`
    otherwise.

    `release` commands are used often to stop moving characters.
  - **oneShot:** `true` if the command must be detected in one frame only.
    `false` otherwise.

    Declaring a command as `oneShot` will _only_ trigger an event when its
    associated input (e.g.: key, pad or button) is _pressed_, and _not_ while
    it is _held down_.

    `oneShot` commands are used often for selecting options in a menu and for
    making a character jump or grab something in a level that needs subsequent
    control, like a ladder or a trellis.
    Note that this kind of command prevents the player from, for example,
    holding the "jump button" to make the character continuosly hop.
]]
function M.setCommand(entityName, input, callback, kind)
  return command.set(entityName, input, callback, kind)
end

function M.run()
  load()
  if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
  if love.timer then love.timer.step() end
  
  local dt = 0
  
  return function()
    if love.event then
      love.event.pump()
      for name, a, b, c, d, e, f in love.event.poll() do
        if name == "quit" then
          if not love.quit or not love.quit() then
            return a or 0
          end
        end
        handlers[name](a, b, c, d, e, f)
        love.handlers[name](a, b, c, d, e, f)
      end
    end
  
    if love.timer then dt = love.timer.step() end
  
    update(dt)
    if love.update then love.update(dt) end
  
    if love.graphics and love.graphics.isActive() then
      love.graphics.origin()
      love.graphics.clear(love.graphics.getBackgroundColor())
  
      draw()
      if love.draw then love.draw() end
  
      love.graphics.present()
    end
  
    if love.timer then love.timer.sleep(0.001) end
  end
end


return M
