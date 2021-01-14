local M = {}

function M.load(config)
  local loaded = {}

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
  loaded.keys = config.keys or {}
  for input, key in pairs(defaults.keys) do
    loaded.keys[input] = loaded.keys[input] or key
  end
  loaded.joystick = config.joystick or {}
  for k, inputs in pairs(defaults.joystick) do
    loaded.joystick[k] = loaded.joystick[k] or {}
    for input, v in pairs(inputs) do
      loaded.joystick[k][input] = loaded.joystick[k][input] or v
    end
  end

  return loaded
end

return M
