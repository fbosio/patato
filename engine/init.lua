--[[--
 The engine itself.
 Contains callbacks and functions that constitute its API.
 @module engine
]]

local config
if not pcall(function() config = require "config" end) then
  config = {
    entities = {
      player = {
        input = {
          walkLeft = "left",
          walkRight = "right",
          walkUp = "up",
          walkDown = "down"
        }
      }
    }
  }
end
if type(config) ~= "table" then
  local message = "Incorrect config, received " .. type(config) .. "."
  if type(config) == "boolean" and config then
    message = message .. "\n"
                      .. "Probably config.lua is empty or you forgot the "
                      .. '"return M" statement.'
  end
  error(message)
end

local entityTagger = require "engine.tagger"
local resourcemanager = require "engine.resourcemanager"
local systems = require "engine.systems"
local renderer = require "engine.renderer"
local command = require "engine.command"

local M = {}


--[[--
 Callbacks.

 Similar to those in [Löve2D](https://love2d.org/wiki/love).

 Call them inside the [Löve2D](https://love2d.org/wiki/love) callbacks of
 the same name.

 @section callbacks
]]

--- Should be called exactly once inside
--  [love.load](https://love2d.org/wiki/love.load)
function M.load()
  systems.load(love, entityTagger)
  resourcemanager.load(love, entityTagger)
  for k, v in pairs(resourcemanager.buildWorld(config)) do
    M[k] = v
  end
  M.collectableEffects = {}
  setmetatable(M.collectableEffects, {
    __index = function ()
      return function () end
    end
  })
  renderer.load(love, entityTagger)
end

--- Should be called inside [love.update](https://love2d.org/wiki/love.update)
-- @tparam number dt Time since the last update in seconds.
function M.update(dt)
  systems.update(dt, M.hid, M.gameState.components, M.collectableEffects,
                 M.resources.animations, M.physics)
end

--- Should be called inside [love.draw](https://love2d.org/wiki/love.draw)
function M.draw()
  renderer.draw(M.gameState.components, M.gameState.inMenu, M.resources)
end

--[[--
 Add it inside [love.keypressed](https://love2d.org/wiki/love.keypressed)

 Triggered just when a key is pressed.

 It is not called after, while the key is held down.
 Ideal for one shot commands, like jumping or selecting options in a menu.
 @tparam string key Character of the pressed key.
]]
function M.keypressed(key)
  systems.keypressed(key, M.hid, M.gameState.components)
end


--[[--
 API

 Engine-specific functions

 @section api
]]

--- Hide menu and load a specific level of the game.
-- @tparam[opt=config.firstLevel] string levelName
--  Name of the level, as defined in `config.lua`.
function M.startGame(levelName)
  M.gameState.inMenu = false
  resourcemanager.buildState(config, M, levelName)
end


--[[--
 Associate a callback to an option of a menu.
 @tparam string entity
  The identifier of the menu, as defined in `config.lua`
 @tparam number index Number of option in the `options` table of the menu
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
 @tparam string name
  The identifier of the collectable, as defined in `config.lua`
 @tparam function callback What the collectable does when collected
 @usage
  engine.setCollectableEffect("healthPotion", function ()
    health = health + 1  -- defined in outer scope
  end)
]]
function M.setCollectableEffect(name, callback)
  M.collectableEffects[name] = callback
end

--[=[--
 Associate a callback to an action.

 An _action_ is triggered when some key is held down by the user.
 The action is identified for an entity by a unique name in its `input`
 component which is defined in @{setInputs}.
 @tparam string action
  The identifier of the input event, as defined in @{setInputs}.
 @tparam function callback What the event triggers.
  The callback receives a table `c` that has the components associated with
  the entity that triggered the input event in the first place.
 @usage
 engine.setAction("walkRight", function (c)
    --[[
      "walkRight" is a field of the input table of an entity in `config.lua`,
       `c` is the components table of that entity.
       In this case, `c` has at least three fields:
       1. `velocity`
       2. `impulseSpeed`
       3. `animation`
       which are tables themselves that have respectively the fields
       1. `x`
       2. `walk`
       3. `name`
    ]]
    c.velocity.x = c.impulseSpeed.walk
    c.animation.name = "walking"
  end)
]=]
function M.setAction(action, callback)
  M.hid.actions[action] = callback
end

--[=[--
  Associate actions of an entity to commands.
  
  A command must be created using @{command}.
  The `input` component of the entity will have stored the actions associated
  to the commands.
  @tparam string entityName Name of the entity, as defined in `config.lua`.
  @tparam table actionCommands Table that has action names as keys and commands
  as values.
  @usage
  engine.setInputs("patato", {
    walkLeft = engine.command{key = "left"},
    walkRight = engine.command{key = "right"},
    stopWalking = engine.command{keys = {"left", "right"}, release = true}
  })
]=]
function M.setInputs(entityName, actionCommands)
  resourcemanager.setInputs(M, entityName, actionCommands)
end

--[=[--
  Create a new command.

  A command is a table that represents a keyboard gesture.
  @tparam table args Arguments for building the command. Valid arguments are:
  
  - **key:** String that represents a key, defined in the `keys` table in 
    `config.lua`. If this argument is set, do not set the `keys` argument.
  - **keys:** Table of strings that represent keys, defined in the `keys`
    table in `config.lua`. If this argument is set, do not set the `key`
    argument.
  - **release:** `true` if the command represents a key-up gesture. `false`
    otherwise.
  - **oneShot:** `true` if the command must be detected in only one frame.
    `false` otherwise.
]=]
function M.command(args)
  return command.new(args)
end

return M
