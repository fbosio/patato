local systems = require "engine.systems"

local M = {}

setmetatable(M, {
  __index = function ()
    return function () end
  end
})

function M.load(engine)
  M.engine = engine
end

function M.keypressed(key)
  systems.keypressed(key, M.engine.hid, M.engine.gameState.components)
end

function M.keyreleased(key)
  systems.keyreleased(key, M.engine.hid, M.engine.gameState.components)
end

function M.joystickadded(joystick)
  systems.joystickadded(joystick, M.engine.hid)
end

function M.joystickremoved(joystick)
  systems.joystickremoved(joystick, M.engine.hid)
end

function M.joystickpressed(joystick, button)
  systems.joystickpressed(joystick, button, M.engine.hid,
                          M.engine.gameState.components)
end

function M.joystickreleased(joystick, button)
  systems.joystickreleased(joystick, button, M.engine.hid,
                          M.engine.gameState.components)
end

function M.joystickhat(joystick, hat, direction)
  systems.joystickhat(joystick, hat, direction, M.engine.hid,
                          M.engine.gameState.components)
end

return M