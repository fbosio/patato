local builder = require "engine.systems.loaders.gamestate.builder"

local M = {}

function M.load(love, entityTagger, hid, config)
  M.entityTagger = entityTagger
  local loaded = {
    components = {
      garbage = {}
    }
  }
  builder.load(love, entityTagger, loaded.components)
  for entityName, entityData in pairs(config.entities or {}) do
    local entity = entityTagger.tag(entityName)
    for k, v in pairs(entityData) do
      builder[k](v, entity, hid)
    end
  end
  return loaded
end

return M
