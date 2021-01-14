local M = {}

function M.load(config)
  return {
    gravity = (config.physics or {}).gravity or 0
  }
end

return M
