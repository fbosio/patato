local tinyyaml = require "tinyyaml"

local M = {}

local function isNull (parsedYaml)
  return not parsedYaml or parsedYaml.isnull and parsedYaml.isnull()
end

function M.load (configYaml)
  local config = #configYaml > 0 and tinyyaml.parse(configYaml) or {}

  M.world = isNull(config.world) and {} or config.world
  M.world.gravity = M.world.gravity or 0

  M.keys = isNull(config.keys) and {} or config.keys
  M.keys.left = M.keys.left or "a"
  M.keys.right = M.keys.right or "d"
  M.keys.up = M.keys.up or "w"
  M.keys.down = M.keys.down or "s"

  if not isNull(config.entities) then
    M.gameState = {}
    for entityName, entity in pairs(config.entities) do
      for componentName, component in pairs(entity) do
        M.gameState[componentName] = M.gameState[componentName] or {}
        M.gameState[componentName][entityName] =
          isNull(component) and {
            left = "left",
            right = "right",
            up = "up",
            down = "down"
          } or component
      end
    end
  end
end

return M
