--[[--
 Contains callbacks for general use and specific functions that constitute its
 API.

 @module engine
]]

local config
pcall(function() config = require "config" end)

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

 A typical project starts just with the @{load}, @{update} and @{draw}
 callbacks. As the game is developed the need for new functionality arises and,
 with it, more specific callbacks are needed as well.

 `oneShot` and `release` keyboard commands require the @{keypressed} and @{keyreleased}
 callbacks, respectively.
 Joystick handling requires @{joystickadded} and @{joystickremoved}.
 `oneShot` and `release` _joystick_ commands require the additional @{joystickhat} and
 @{joystickpressed} callbacks.

 See @{command} for an explanation of the `oneShot` and `release` parameters.

 @section callbacks
 ]]

--[[--
 Call it inside [love.load](https://love2d.org/wiki/love.load).

 Required if you call @{engine.update}.

 @usage
  function love.load()
    engine.load()
  end
]]
function M.load()
  systems.load(love, entityTagger)
  resourcemanager.load(love, entityTagger)

  local emptyConfig = not config
  if emptyConfig then
    config = {
      entities = {
        player = {
          input = true
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

  for k, v in pairs(resourcemanager.buildWorld(config)) do
    M[k] = v
  end

  if emptyConfig then
    M.setInputs("player", {
      walkLeft = M.command{key = "left"},
      walkRight = M.command{key = "right"},
      walkUp = M.command{key = "up"},
      walkDown = M.command{key = "down"},
      stopWalkingHorizontally = M.command{
        keys = {"left", "right"},
        release = true
      },
      stopWalkingVertically = M.command{
        keys = {"up", "down"},
        release = true
      },
    })
  end

  M.collectableEffects = {}
  setmetatable(M.collectableEffects, {
    __index = function ()
      return function () end
    end
  })
  renderer.load(love, entityTagger)
end

--[[--
 Call it inside [love.update](https://love2d.org/wiki/love.update).

 A previous call to @{engine.load} is required by this callback in order to
 work.

 @tparam number dt Time since the last update in seconds.
 @usage
  function love.load()
    engine.load()
  end

  function love.update(dt)
    engine.update(dt)
  end
]]
function M.update(dt)
  systems.update(dt, M.hid, M.gameState.components, M.collectableEffects,
                 M.resources.animations, M.physics)
end

--[[--
 Call it inside [love.draw](https://love2d.org/wiki/love.draw).

 @usage
  function love.draw()
    engine.draw()
  end
]]
function M.draw()
  renderer.draw(M.gameState.components, M.gameState.inMenu, M.resources)
end

--[[--
 Call it inside [love.keypressed](https://love2d.org/wiki/love.keypressed).

 Capture an event only when a key is pressed and not while it is held down.

 Required for _one shot keyboard commands_.
 @tparam string key Character of the pressed key.
 @usage
  function love.keypressed(key)
    engine.keypressed(key)
  end
 @see setInputs
 @see command
]]
function M.keypressed(key)
  systems.keypressed(key, M.hid, M.gameState.components)
end

--[[--
 Call it inside [love.keyreleased](https://love2d.org/wiki/love.keyreleased).

 Needed for _release keyboard commands_.
 @tparam string key Character of the pressed key.
 @usage
  function love.keyreleased(key)
    engine.keyreleased(key)
  end
 @see setInputs
 @see command
]]
function M.keyreleased(key)
  systems.keyreleased(key, M.hid, M.gameState.components)
end

--[[--
 Call it inside
 [love.joystickadded](https://love2d.org/wiki/love.joystickadded).

 @tparam Joystick joystick The newly connected
  [Joystick object](https://love2d.org/wiki/Joystick).
 @usage
  function love.joystickadded(joystick)
    engine.joystickadded(joystick)
  end
]]
function M.joystickadded(joystick)
  systems.joystickadded(joystick, M.hid)
end

--[[--
 Call it inside
 [love.joystickpressed](https://love2d.org/wiki/love.joystickpressed).

 @tparam Joystick joystick The
  [joystick object](https://love2d.org/wiki/Joystick).
 @tparam number button The button number.
 @usage
  function love.joystickpressed(joystick, button)
    engine.joystickpressed(joystick, button)
  end
]]
function M.joystickpressed(joystick, button)
  systems.joystickpressed(joystick, button, M.hid, M.gameState.components)
end

--[[--
 Call it inside [love.joystickhat](https://love2d.org/wiki/love.joystickhat).

 @tparam Joystick joystick The
  [joystick object](https://love2d.org/wiki/Joystick).
 @tparam number hat The hat number.
 @tparam JoystickHat direction The new [hat direction](https://love2d.org/wiki/JoystickHat).
 @usage
  function love.joystickhat(joystick, hat, direction)
    engine.joystickhat(joystick, hat, direction)
  end
]]
function M.joystickhat(joystick, hat, direction)
  systems.joystickhat(joystick, hat, direction, M.hid, M.gameState.components)
end

--[[--
 Call it inside
 [love.joystickremoved](https://love2d.org/wiki/love.joystickremoved).

 @tparam Joystick joystick Called when a
  [Joystick](https://love2d.org/wiki/Joystick) is disconnected.
 @usage
  function love.joystickremoved(joystick)
    engine.joystickremoved(joystick)
  end
]]
function M.joystickremoved(joystick)
  systems.joystickremoved(joystick, M.hid)
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
  M.gameState.inMenu = false
  resourcemanager.buildState(config, M, level)
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


--[=[--
 Associate a callback to an action.

 An _action_ is triggered by a _command_.
 For an entity, the action is identified by a unique name which is defined when
 calling @{setInputs}.
 @tparam string action
  The identifier of the input event, as defined in @{setInputs}.
 @tparam function callback What the event triggers.
  The callback receives a table `c` that has the components associated with
  the entity that triggered the input event in the first place.
 @usage
 engine.setAction("walkRight", function (c)
   --[[
       `c` is the components table of the entity.
       In this case, `c` has at least three fields:
       1. `velocity`
       2. `impulseSpeed`
       3. `animation`
       whose values are tables themselves that have respectively the fields
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


--[[--
  Associate actions of an entity to commands.

  Callbacks for actions are set using @{setAction}.
  Commands are created using @{command}.
  @tparam string entity
   The identifier of the entity, as defined in `config.lua`
  @tparam table actionCommands Table that has action names as fields and
  commands as values.
  @usage
  engine.setInputs("hero", {
    walkLeft = engine.command{key = "left"},
    walkRight = engine.command{key = "right"},
    stopWalking = engine.command{keys = {"left", "right"}, release = true},
    jump = engine.command{key = "jump", oneShot = true}
  })
]]
function M.setInputs(entity, actionCommands)
  resourcemanager.setInputs(M, entity, actionCommands)
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
function M.command(args)
  return command.new(args)
end


return M
