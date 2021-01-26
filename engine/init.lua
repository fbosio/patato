--[[--
 Contains a callback for general use and specific functions that constitute its
 API.

 @module engine
]]

local config = require "config"
local entityTagger = require "engine.tagger"
local systems = require "engine.systems"
local command = require "engine.command"
local handlers = require "engine.handlers"


local M = {}

--[[--
 Callback

 The engine Swiss Army knife for communicating with
 [Löve2D](https://love2d.org/).

 @section callback
]]

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
  systems.update(dt, M.gameState, M.resources, M.physics)
end

local function draw()
  systems.draw(M.gameState, M.resources, M.release)
end

--[[--
 All-in-one callback.
 
 Load, update, draw and handle [Löve2D events](https://love2d.org/wiki/Event)
 from the same place.

 @usage
  love.run = engine.run
]]
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
  M.gameState.components, M.gameState.inMenu =
    systems.reload(level, M.gameState.inMenu)
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
  M.gameState.menu = M.gameState.menu or {}
  M.gameState.menu[entity] = M.gameState.menu[entity] or {}
  M.gameState.menu[entity][index] = callback
end

function M.getMenuOptionEffect(entity, index)
  return M.gameState.menu[entity][index] or function () end
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
  M.gameState.collectableEffects[entity] = callback
end


--[=[--
  Set a command for an entity.

  @tparam string entity Name of the entity.
  
  @tparam string input Input that will trigger the command. Specified in the
    `inputs` table in `config.lua`.

  @tparam function callback What to do when the command is triggered.
    It receives a table that has the entity components.
  
  @tparam string kind Must be one of the following.

  - `"press"`
  - `"hold"`
  - `"release"`
 
  @usage
    --[[ Example config.lua
      local M = {}

      M.inputs = {
        keyboard = {
          right = "d",
          jump = "space"
        }
      }

      M.entities = {
        player = {
          flags = {"controllable"},
          impulseSpeed = {
            walk = 500,
            jump = 1000
          }
        }
      }

      return M
    ]]
    engine.setCommand("player", "right", function (t)
      t.velocity.x = t.impulseSpeed.walk
    end, "hold")
    engine.setCommand("player", "jump", function (t)
      t.velocity.y = -t.impulseSpeed.jump
    end, "press")
    engine.setCommand("player", "right", function (t)
      t.velocity.x = 0
    end, "release")
]=]
function M.setCommand(entity, input, callback, kind)
  command.set(entity, input, callback, kind)
end

function M.setCameraTarget(targetEntity, focusCallback)
  M.gameState.camera = M.gameState.camera or {}
  M.gameState.camera.target = targetEntity
  M.gameState.camera.focusCallback = focusCallback
end

function M.playSfx(name)
  M.resources.sounds.sfx[name]:play()
end

return M
