local M = {}

function M.load(config)
  if not config then
    return {
      entities = {
        player = {
          flags = {"controllable"}
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

  return config
end

return M
