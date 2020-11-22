local tinyyaml = require "tinyyaml"

local M = {}

local function isNull (parsedYaml)
  return not parsedYaml or parsedYaml.isnull and parsedYaml.isnull()
end

function M.load (configYaml)
  local config = #configYaml > 0 and tinyyaml.parse(configYaml) or {}
  M.world = config.world or {}
  M.world.gravity = isNull(config.world) and 0 or config.world.gravity
  M.keys = isNull(config.keys)
           and {left = "a", right = "d", up = "w", down = "s"} or config.keys
end

return M
