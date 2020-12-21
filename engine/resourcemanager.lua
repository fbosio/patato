local M = {}

local function setComponent(world, componentName, entity, value)
  world.gameState[componentName] = world.gameState[componentName] or {}
  world.gameState[componentName][entity] = value
end

local function setComponentAttribute(world, componentName, entity,
    attribute, value)
  world.gameState[componentName] = world.gameState[componentName] or {}
  world.gameState[componentName][entity] =
    world.gameState[componentName][entity] or {}
  world.gameState[componentName][entity][attribute] = value
end

local function copyInputToState(world, input, entity, foundMenu)
  if not next(input) then  -- check that input (non-boolean) is an empty table
    local defaultInput = foundMenu and {
      menuPrevious = "up",
      menuNext = "down",
      menuSelect = "start"
    } or {
      walkLeft = "left",
      walkRight = "right",
      walkUp = "up",
      walkDown = "down"
    }
    for actionName, defaultKey in pairs(defaultInput) do
      input[actionName] = input[actionName] or defaultKey
    end
  end
  for actionName, virtualKey in pairs(input) do
    if world.keys[virtualKey] then
      setComponentAttribute(world, "input", entity, actionName,
                            virtualKey)
    end
  end
end

local function createDefaultPosition(world, entity)
  local width, height = M.love.graphics.getDimensions()
  setComponentAttribute(world, "position", entity, "x", width/2)
  setComponentAttribute(world, "position", entity, "y", height/2)
end

local function createDefaults(world, entity)
  setComponentAttribute(world, "impulseSpeed", entity, "walk", 400)
  createDefaultPosition(world, entity)
  setComponentAttribute(world, "velocity", entity, "x", 0)
  setComponentAttribute(world, "velocity", entity, "y", 0)
end

local function copyMenuToState(world, menu, entity)
  local menuOptions = {}
  for _, option in ipairs(menu.options) do
    menuOptions[#menuOptions+1] = option
  end
  setComponentAttribute(world, "menu", entity, "options", menuOptions)
  setComponentAttribute(world, "menu", entity, "callbacks", {})
  setComponentAttribute(world, "menu", entity, "selected", 1)
  world.inMenu = true  -- cambiar por escena
end

local stateBuilders = {
  input = function (world, component, entity)
    copyInputToState(world, component, entity)
    createDefaults(world, entity)
  end,
  impulseSpeed = function (world, component, entity)
    for impulseName, speed in pairs(component) do
      setComponentAttribute(world, "impulseSpeed", entity, impulseName,
                            speed)
    end
  end,
  collector = function (world, component, entity)
    setComponent(world, "collector", entity, component)
  end,
  collectable = function (world, _, entity)
    setComponent(world, "collectable", entity,
                 {name=M.tagger.getName(entity)})
  end,
  collisionBox = function (world, component, entity)
    local t = {
      origin = {x=component[1], y=component[2]},
      width = component[3],
      height = component[4],
      x = 0,
      y = 0
    }
    for k, v in pairs(t) do
      setComponentAttribute(world, "collisionBox", entity, k, v)
    end
    createDefaultPosition(world, entity)
  end
}

local function buildNonMenu(entityName, entityComponents, world)
  local entity = nil
  if not entityComponents.menu then
    for componentName, component in pairs(entityComponents) do
      if componentName ~= "menu" then
        entity = entity or M.tagger.tag(entityName)
        assert(stateBuilders[componentName],
        "Entity " .. entityName .. " has a component named "
        .. componentName .. " that was not expected in config.lua")
        stateBuilders[componentName](world, component, entity)
      end
    end
  end
  return entity
end

local function buildMenu(config, world)
  local foundMenu = false
  for entityName, entityComponents in pairs(config.entities) do
    for componentName, component in pairs(entityComponents) do
      if componentName == "menu" and world.inMenu == nil then
        local entity = M.tagger.tag(entityName)
        foundMenu = true
        copyMenuToState(world, component, entity)
        world.gameState.input = world.gameState.input or {}
        world.gameState.input[entity] = entityComponents.input
        copyInputToState(world, world.gameState.input[entity] or {},
                         entity, true)
      end
    end
  end

  return not foundMenu
end

local function buildNonMenuIfInLevel(config, world, levelName, entityName,
                                     entityComponents)
  local firstLevelName = config.firstLevel or next(config.levels)
  levelName = levelName or firstLevelName
  local level = config.levels[levelName] or {}
  local positions = level[entityName]
  if positions then
    if type(positions[1]) == "number" then
      positions = {positions}
    end
    for _, position in ipairs(positions) do
      local entity = buildNonMenu(entityName, entityComponents, world)
      if entity then
        setComponentAttribute(world, "position", entity, "x", position[1])
        setComponentAttribute(world, "position", entity, "y", position[2])
      end
    end
  end
end

local function buildAssets(config, world)
  if config.spriteSheet and config.sprites then
    local spriteSheet = M.love.graphics.newImage(config.spriteSheet)
    world.sprites = {}
    for _, spriteData in ipairs(config.sprites) do
      local x, y, w, h, originX, originY = unpack(spriteData)
      local newSprite = {}
      newSprite.quad = M.love.graphics.newQuad(x, y, w, h,
                                               spriteSheet:getDimensions())
      newSprite.origin = {x = originX, y = originY}
      world.sprites[#world.sprites+1] = newSprite
    end
  end
end

function M.buildState(config, world, levelName)
  world.gameState = {garbage={}}
  if config.entities then
    local hasNoMenuComponents = buildMenu(config, world)
    if hasNoMenuComponents then
      for entityName, entityComponents in pairs(config.entities) do
        if config.levels then
          buildNonMenuIfInLevel(config, world, levelName, entityName,
                                entityComponents)
        else
          local isNotCollectable = not config.entities[entityName].collectable
          local isNotCollector = not config.entities[entityName].collector
          assert(isNotCollectable or isNotCollector,
                 "Entities must not be collectables and collectors at the "
                 .. "same time, but entity " .. entityName .. " has both "
                 .. "components declared in config.lua")
          if isNotCollectable then
            buildNonMenu(entityName, entityComponents, world)
          end
        end
      end
    end
  end
end

function M.load(love, tagger)
  M.love = love
  M.tagger = tagger
end

function M.buildWorld(config)
  local world = {}

  world.physics = config.physics or {}
  world.physics.gravity = world.physics.gravity or 0

  world.keys = config.keys or {}
  world.keys.left = world.keys.left or "a"
  world.keys.right = world.keys.right or "d"
  world.keys.up = world.keys.up or "w"
  world.keys.down = world.keys.down or "s"
  world.keys.start = world.keys.start or "return"

  buildAssets(config, world)
  M.buildState(config, world)

  return world
end

return M
