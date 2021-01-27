local M = {}

function M.load(love, entityTagger)
  M.love = love
  M.entityTagger = entityTagger
end

function M.update(hid)
  for name, physicalKey in pairs(hid.keys) do
    if M.love.keyboard.isDown(physicalKey) then
      hid.commands.press[name] = false
      hid.commands.hold[name] = true
    end
  end

  if hid.joystick.current then
    for name, physicalHat in pairs(hid.joystick.hats) do
      if hid.joystick.current:getHat() == physicalHat then
        hid.commands.press[name] = false
        hid.commands.hold[name] = true
      end
    end
    for name, physicalButton in pairs(hid.joystick.buttons) do
      if hid.joystick.current:isDown(physicalButton) then
        hid.commands.press[name] = false
        hid.commands.hold[name] = true
      end
    end
  end
end

local function checkEvent(input, hidInputs, commandKind, commands)
  for name, physicalInput in pairs(hidInputs) do
    if input == physicalInput then
      for kind, _ in pairs(commands) do
        commands[kind][name] = commandKind == kind
      end
    end
  end
end

function M.keypressed(key, hid)
  checkEvent(key, hid.keys, "press", hid.commands)
end

function M.keyreleased(key, hid)
  checkEvent(key, hid.keys, "release", hid.commands)
end

function M.joystickadded(joystick, hid)
  hid.joystick.current = hid.joystick.current or joystick
end

function M.joystickremoved(joystick, hid)
  hid.joystick.current = hid.joystick.current == joystick and nil
                         or hid.joystick.current
end

function M.joystickhat(joystick, hat, direction, hid)
  if joystick == hid.joystick.current and hat == 1 then
    if direction == "c" then
      for name, _ in pairs(hid.joystick.hats) do
        if hid.commands.hold[name] or hid.commands.press[name] then
          hid.commands.press[name] = false
          hid.commands.hold[name] = false
          hid.commands.release[name] = true
        end
      end
    else
      checkEvent(direction, hid.joystick.hats, "press", hid.commands)
    end
  end
end

function M.joystickpressed(joystick, button, hid)
  if joystick == hid.joystick.current then
    checkEvent(button, hid.joystick.buttons, "press", hid.commands)
  end
end

function M.joystickreleased(joystick, button, hid)
  if joystick == hid.joystick.current then
    checkEvent(button, hid.joystick.buttons, "release", hid.commands)
  end
end

return M
