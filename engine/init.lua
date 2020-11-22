local tinyyaml = require "tinyyaml"

local M = {}

function M.load (config_yaml)
  local config
  if #config_yaml > 0 then
    config = tinyyaml.parse(config_yaml)
  else
    config = {
      world = {gravity = 0}
    }
  end
  M.world = config.world
end

return M
