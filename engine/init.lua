local tinyyaml = require "tinyyaml"

local M = {}

function M.load (config_yaml)
  local config = #config_yaml > 0 and tinyyaml.parse(config_yaml) or {}
  M.world = config.world or {}
  M.world.gravity = (not config.world or config.world.isnull()) and 0
                    or config.world.gravity
end

return M
