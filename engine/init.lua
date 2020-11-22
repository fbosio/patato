local tinyyaml = require "tinyyaml"

local M = {}

function M.load (config_yaml)
  local config = #config_yaml > 0 and tinyyaml.parse(config_yaml) or {}
  M.world = config.world or {}
  M.world.gravity = M.world.gravity or 0
end

return M
