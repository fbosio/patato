local M = {}

function M.load(config)
  local loaded = {
    commands = {press = {}, hold = {}, release = {}}
  }

  local defaults = {
    keys = {
      left = "a",
      right = "d",
      up = "w",
      down = "s",
      start = "return"
    },
    joystick = {
      hats = {
        left = "l",
        right = "r",
        up = "u",
        down = "d"
      },
      buttons = {
        start = 10
      }
    }
  }
  loaded.keys = (config.inputs or {}).keyboard or {}
  for input, key in pairs(defaults.keys) do
    loaded.keys[input] = loaded.keys[input] or key
  end
  loaded.joystick = (config.inputs or {}).joystick or {}
  for k, inputs in pairs(defaults.joystick) do
    loaded.joystick[k] = loaded.joystick[k] or {}
    for input, v in pairs(inputs) do
      loaded.joystick[k][input] = loaded.joystick[k][input] or v
    end
  end
  for _, t in ipairs{loaded.keys, loaded.joystick.hats,
                     loaded.joystick.buttons} do
    for input, _ in pairs(t) do
      loaded.commands.press[input] = false
      loaded.commands.hold[input] = false
      loaded.commands.release[input] = false
    end
  end
  
  return loaded
end

return M
