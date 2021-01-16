local builder = require "engine.systems.loaders.gamestate.builder"

local M = {}

local function getFlattenedData(data)
  local flattened = {}
  for k, v in pairs(data) do
    if k == "flags" then
      for _, flag in ipairs(v) do
        flattened[flag] = true
      end
    else
      flattened[k] = true
    end
  end
  return flattened
end

local function checkEntitiesCompatibility(entities)
  local incompatiblePairs = {
    {"collectable", "collector"},
    {"collideable", "solid"},
    {"climber", "trellis"}
  }
  for name, data in pairs(entities or {}) do
    local flattened = getFlattenedData(data)
    for _, pair in ipairs(incompatiblePairs) do
      assert(not (flattened[pair[1]] and flattened[pair[2]]),
             "Found entity \"" .. name .. "\" declared as both " .. pair[1]
             .. " and " .. pair[2] .. "in config.lua")
    end
    assert(not (data.collideable == "triangle" and flattened.trellis),
           "Found entity \"" .. name .. "\" declared as both slope and trellis"
           .. "in config.lua")
  end
end

local function getMenuEntities(entities)
  for name, entityData in pairs(entities or {}) do
    if entityData.menu then return name end
  end
end

local function buildEntity(name, data, entityTagger)
  local entity = entityTagger.tag(name)
  for k, v in pairs(data) do
    if k ~= "load" and k ~= "buildFromVertices" then
      builder[k](v, entity)
    end
  end
  return entity
end

local function buildEntitiesInLevels(config, entityTagger)
  for entityName, entityData in pairs(config.entities or {}) do
    local firstLevel = config.firstLevel or next(config.levels)
    local levelData = config.levels[firstLevel] or {}
    local levelEntityData = levelData[entityName]
    if levelEntityData then
      if type(levelEntityData[1]) ~= "table" then
        levelEntityData = {levelEntityData}
      end
      for _, vertices in ipairs(levelEntityData) do
        local entity = buildEntity(entityName, entityData, entityTagger)
        builder.buildFromVertices(vertices, entity, entityData)
      end
    end
  end
end

local function buildDefaults(entities, entityTagger)
  for name, data in pairs(entities or {}) do
    local mustBeBuilt = not data.collideable
    if not mustBeBuilt then break end
    for _, flag in ipairs(data.flags or {}) do
      if flag == "collectable" or flag == "trellis" then
        mustBeBuilt = false
        break
      end
    end
    if mustBeBuilt then
      buildEntity(name, data, entityTagger)
    end
  end
end

function M.load(love, entityTagger, command, config)
  M.entityTagger = entityTagger
  local loaded = {
    components = {
      garbage = {}
    }
  }
  checkEntitiesCompatibility(config.entities)
  local menuName = getMenuEntities(config.entities)
  builder.load(love, entityTagger, command, menuName, loaded.components)
  if menuName then
    buildEntity(menuName, config.entities[menuName], entityTagger)
  elseif config.levels then
    buildEntitiesInLevels(config, entityTagger)
  else
    buildDefaults(config.entities, entityTagger)
  end
  return loaded
end

return M
