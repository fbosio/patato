local builder = require "engine.systems.loaders.gamestate.builder"

local M = {}

local function getMenuEntities(entities)
  for name, entityData in pairs(entities or {}) do
    if entityData.menu then return name end
  end
end

local function buildEntity(name, data, entityTagger, hid)
  local entity = entityTagger.tag(name)
  for k, v in pairs(data) do
    builder[k](v, entity, hid)
  end
end

function M.load(love, entityTagger, hid, config)
  M.entityTagger = entityTagger
  local loaded = {
    components = {
      garbage = {}
    }
  }
  local menuName = getMenuEntities(config.entities)
  builder.load(love, entityTagger, menuName, loaded.components)
  if menuName then
    buildEntity(menuName, config.entities[menuName], entityTagger, hid)
  else
    for name, data in pairs(config.entities or {}) do
      buildEntity(name, data, entityTagger, hid)
    end
  end
  return loaded
end

return M
