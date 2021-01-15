local builder = require "engine.systems.loaders.gamestate.builder"

local M = {}

local function checkEntitiesCompatibility(entities)
  for name, data in pairs(entities or {}) do
    local foundCollectable = false
    for _, flag in ipairs(data.flags or {}) do
      if flag == "collectable" then
        foundCollectable = true
      end
    end
    for _, flag in ipairs(data.flags or {}) do
      assert(foundCollectable and flag ~= "collector" or not foundCollectable,
             "Entities must not be collectables and collectors at the same"
             .. "time, but entity \"" .. name .. "\" has both "
             .. "components declared in config.lua")
    end
  end
end

local function getMenuEntities(entities)
  for name, entityData in pairs(entities or {}) do
    if entityData.menu then return name end
  end
end

local function buildEntity(name, data, entityTagger, hid)
  local entity = entityTagger.tag(name)
  for k, v in pairs(data) do
    if k ~= "load" and k ~= "buildFromVertices" then
      builder[k](v, entity, hid)
    end
  end
  return entity
end

local function buildEntitiesInLevels(config, entityTagger, hid)
  for entityName, entityData in pairs(config.entities or {}) do
    local firstLevel = config.firstLevel or next(config.levels)
    local levelData = config.levels[firstLevel] or {}
    local levelEntityData = levelData[entityName]
    if levelEntityData then
      if type(levelEntityData[1]) ~= "table" then
        levelEntityData = {levelEntityData}
      end
      for _, vertices in ipairs(levelEntityData) do
        local entity = buildEntity(entityName, entityData, entityTagger, hid)
        builder.buildFromVertices(vertices, entity, entityData)
      end
    end
  end
end

local function buildDefaults(entities, entityTagger, hid)
  for name, data in pairs(entities or {}) do
    local mustBeBuilt = not data.collideable
    if not mustBeBuilt then break end
    for _, flag in ipairs(data.flags or {}) do
      if flag == "collectable" then
        mustBeBuilt = false
        break
      end
    end
    if mustBeBuilt then
      buildEntity(name, data, entityTagger, hid)
    end
  end
end

function M.load(love, entityTagger, hid, config)
  M.entityTagger = entityTagger
  local loaded = {
    components = {
      garbage = {}
    }
  }
  checkEntitiesCompatibility(config.entities)
  local menuName = getMenuEntities(config.entities)
  builder.load(love, entityTagger, menuName, loaded.components)
  if menuName then
    buildEntity(menuName, config.entities[menuName], entityTagger, hid)
  elseif config.levels then
    buildEntitiesInLevels(config, entityTagger, hid)
  else
    buildDefaults(config.entities, entityTagger, hid)
  end
  return loaded
end

return M
