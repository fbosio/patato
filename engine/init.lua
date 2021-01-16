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
  local world = systems.load(love, entityTagger, command, config)

  for k, v in pairs(world) do
    M[k] = v
  end

  if not config then
    -- TODO: hello world
  end
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
                 M.resources, M.physics)
end

--[[--
 Call it inside [love.draw](https://love2d.org/wiki/love.draw).

 @usage
  function love.draw()
    engine.draw()
  end
]]
function M.draw()
  systems.draw(M.gameState.components, M.gameState.inMenu, M.resources,
               M.release)
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


return M
