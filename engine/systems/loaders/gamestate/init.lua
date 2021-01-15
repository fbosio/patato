local builder = require "engine.systems.loaders.gamestate.builder"
local component = require "engine.systems.loaders.gamestate.component"

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
  return entity
end

function M.load(love, entityTagger, hid, config)
  M.entityTagger = entityTagger
  local loaded = {
    components = {
      garbage = {}
    }
  }
  local menuName = getMenuEntities(config.entities)
  component.load(love, loaded.components)
  builder.load(entityTagger, menuName, component)
  if menuName then
    buildEntity(menuName, config.entities[menuName], entityTagger, hid)
  elseif config.levels then
    for entityName, entityData in pairs(config.entities or {}) do
      local firstLevel = config.firstLevel or next(config.levels)
      local levelData = config.levels[firstLevel] or {}
      local position = levelData[entityName]
      if position then
        local entity = buildEntity(entityName, entityData, entityTagger,
                                    hid)
        component.setAttribute("position", entity, "x", position[1])
        component.setAttribute("position", entity, "y", position[2])
      end
    end
  else
    for name, data in pairs(config.entities or {}) do
      buildEntity(name, data, entityTagger, hid)
    end
  end
  return loaded
end

return M
