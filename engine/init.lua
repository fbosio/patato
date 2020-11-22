local tinyyaml = require "tinyyaml"

local M = {}

local function isNull (parsedYaml)
  return not parsedYaml or parsedYaml.isnull and parsedYaml.isnull()
end

function M.load (configYaml)
  local config = #configYaml > 0 and tinyyaml.parse(configYaml) or {}
  M.world = config.world or {}
  M.world.gravity = isNull(config.world) and 0 or config.world.gravity
end

return M
