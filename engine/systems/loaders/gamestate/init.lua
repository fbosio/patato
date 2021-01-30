local builder = require "engine.systems.loaders.gamestate.builder"
local collectableeffects =
  require "engine.systems.loaders.gamestate.collectableeffects"
local hid = require "engine.systems.loaders.gamestate.hid"

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
  local cameraName, windowName
  for name, entityData in pairs(M.config.entities or {}) do
    for _, flag in ipairs(entityData.flags or {}) do
      if flag == "camera" then
        cameraName = name
        break
      elseif flag == "window" then
        windowName = name
        break
      end
    end
  end
  return cameraName, windowName
end

local function buildEntity(name)
  local entity = M.entityTagger.tag(name)
  for k, v in pairs(M.config.entities[name]) do
    if k ~= "load" and k ~= "buildFromVertices" and k ~= "buildMusic" then
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
      if type(levelEntityData) == "string" then
        for _, flag in pairs(entityData.flags or {}) do
          if flag == "musicalizer" then
            local entity = buildEntity(entityName)
            builder.buildMusic(levelEntityData, entity)
            break
          end
        end
      else
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
  local components = {garbage = {}}
  M.entityTagger.clear()
  checkEntitiesCompatibility()
  local menuName = getMenuEntity()
  builder.load(M.love, M.entityTagger, menuName, components)
  if menuName and not inMenu then
    buildEntity(menuName)
    inMenu = true
  elseif M.config.levels then
    inMenu = false
    buildEntitiesInLevels(level)
  else
    inMenu = false
    buildDefaults()
  end
  local cameraName, windowName = getCameraEntity()
  if cameraName then buildEntity(cameraName) end
  if windowName and not inMenu then buildEntity(windowName) end
  return components, inMenu
end

function M.load(love, entityTagger, config)
  M.love = love
  M.entityTagger = entityTagger
  M.config = config
  local loaded = {menu = {}, camera = {}}
  loaded.hid = hid.load(config)
  M.hid = loaded.hid
  loaded.components, loaded.inMenu = M.reload()
  loaded.collectableEffects = collectableeffects.load()
  return loaded
end

return M
