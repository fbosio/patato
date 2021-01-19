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

local function checkEntitiesCompatibility()
  local incompatiblePairs = {
    {"collectable", "collector"},
    {"collideable", "solid"},
    {"climber", "trellis"}
  }
  for name, data in pairs(M.config.entities or {}) do
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

local function getMenuEntity()
  for name, entityData in pairs(M.config.entities or {}) do
    if entityData.menu then return name end
  end
end

local function getCameraEntity()
  for name, entityData in pairs(M.config.entities or {}) do
    for _, flag in ipairs(entityData.flags or {}) do
      if flag == "camera" then
        return name
      end
    end
  end
end

local function buildEntity(name)
  local entity = M.entityTagger.tag(name)
  for k, v in pairs(M.config.entities[name]) do
    if k ~= "load" and k ~= "buildFromVertices" then
      assert(builder[k], "Unexpected component \"" .. k .. "\" for entity \""
             .. name .. "\" in config.lua")(v, entity)
    end
  end
  return entity
end

local function buildEntitiesInLevels(level)
  for entityName, entityData in pairs(M.config.entities or {}) do
    local firstLevel = M.config.firstLevel or next(M.config.levels)
    local levelData = M.config.levels[level or firstLevel] or {}
    local levelEntityData = levelData[entityName]
    if levelEntityData then
      if type(levelEntityData[1]) ~= "table" then
        levelEntityData = {levelEntityData}
      end
      for _, vertices in ipairs(levelEntityData) do
        local entity = buildEntity(entityName)
        builder.buildFromVertices(vertices, entity, entityData)
      end
    end
  end
end

local function buildDefaults()
  for name, data in pairs(M.config.entities or {}) do
    local mustBeBuilt = not data.collideable
    if not mustBeBuilt then break end
    for _, flag in ipairs(data.flags or {}) do
      if flag == "collectable" or flag == "trellis" then
        mustBeBuilt = false
        break
      end
    end
    if mustBeBuilt then
      buildEntity(name)
    end
  end
end

function M.reload(level, inMenu)
  local loaded = {
    inMenu = inMenu,
    components = {
      garbage = {}
    }
  }
  M.entityTagger.clear()
  M.command.load(M.hid, loaded.components)
  checkEntitiesCompatibility()
  local menuName = getMenuEntity()
  builder.load(M.love, M.entityTagger, M.command, menuName, loaded.components)
  if menuName and not loaded.inMenu then
    buildEntity(menuName)
    loaded.inMenu = true
  elseif M.config.levels then
    loaded.inMenu = false
    buildEntitiesInLevels(level)
  else
    loaded.inMenu = false
    buildDefaults()
  end
  local cameraName = getCameraEntity()
  if cameraName then buildEntity(cameraName) end
  return loaded
end

function M.load(love, entityTagger, command, hid, config)
  M.love = love
  M.entityTagger = entityTagger
  M.hid = hid
  M.command = command
  M.config = config
  return M.reload()
end

return M
