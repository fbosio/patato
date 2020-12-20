local M = {}

local function setComponent(world, componentName, entityName, value)
  world.gameState[componentName] = world.gameState[componentName] or {}
  world.gameState[componentName][entityName] = value
end

local function setComponentAttribute(world, componentName, entityName,
    attribute, value)
  world.gameState[componentName] = world.gameState[componentName] or {}
  world.gameState[componentName][entityName] =
    world.gameState[componentName][entityName] or {}
  world.gameState[componentName][entityName][attribute] = value
end

local function copyInputToState(world, input, entityName, foundMenu)
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
      setComponentAttribute(world, "input", entityName, actionName,
                            virtualKey)
    end
  end
end

local function createDefaults(world, entityName)
  setComponentAttribute(world, "impulseSpeed", entityName, "walk", 400)
  local width, height = M.love.graphics.getDimensions()
  setComponentAttribute(world, "position", entityName, "x", width/2)
  setComponentAttribute(world, "position", entityName, "y", height/2)
  setComponentAttribute(world, "velocity", entityName, "x", 0)
  setComponentAttribute(world, "velocity", entityName, "y", 0)
end

local function copyMenuToState(world, menu, entityName)
  local menuOptions = {}
  for _, option in ipairs(menu.options) do
    menuOptions[#menuOptions+1] = option
  end
  setComponentAttribute(world, "menu", entityName, "options", menuOptions)
  setComponentAttribute(world, "menu", entityName, "callbacks", {})
  setComponentAttribute(world, "menu", entityName, "selected", 1)
  world.inMenu = true  -- cambiar por escena
end

local stateBuilders = {
  input = function (world, component, entityName)
    copyInputToState(world, component, entityName)
    createDefaults(world, entityName)
  end,
  impulseSpeed = function (world, component, entityName)
    for impulseName, speed in pairs(component) do
      setComponentAttribute(world, "impulseSpeed", entityName, impulseName,
                            speed)
    end
  end,
  collector = function (world, component, entityName)
    setComponent(world, "collector", entityName, component)
  end,
  collectable = function (world, component, entityName)
    setComponent(world, "collectable", entityName, component)
  end,
  collisionBox = function (world, component, entityName)
    local attribute = {"x", "y", "width", "height"}
    for i, value in ipairs(component) do
      setComponentAttribute(world, "collisionBox", entityName, attribute[i],
                            value)
    end
  end
}

local function buildNonMenu(entityName, entity, world)
  if not entity.menu then
    local isCollectable = false
    local isCollector = false
    for componentName, component in pairs(entity) do
      if componentName ~= "menu" then
        if componentName == "collectable" then
          isCollectable = true
        end
        if componentName == "collector" then
          isCollector = true
        end
        assert(not (isCollectable and isCollector),
               "Entities must not be collectables and collectors at the "
                .. "same time, but entity " .. entityName .. " has both "
                .. "components declared in config.lua")
        assert(stateBuilders[componentName],
               "Unexpected component in config.lua: " .. componentName)
        stateBuilders[componentName](world, component, entityName)
      end
    end
  end
end

local function buildMenu(config, world)
  local foundMenu = false
  for entityName, entity in pairs(config.entities) do
    for componentName, component in pairs(entity) do
      if componentName == "menu" and world.inMenu == nil then
        foundMenu = true
        copyMenuToState(world, component, entityName)
        world.gameState.input = world.gameState.input or {}
        world.gameState.input[entityName] = entity.input
        copyInputToState(world, world.gameState.input[entityName] or {},
                          entityName, true)
      end
    end
  end

  return not foundMenu
end

function M.buildState(config, world, levelName)
  world.gameState = {}
  if config.entities then
    local hasNoMenuComponents = buildMenu(config, world)
    if hasNoMenuComponents then
      for entityName, entity in pairs(config.entities) do
        if config.levels then
          local firstLevelName = config.firstLevel or next(config.levels)
          levelName = levelName or firstLevelName
          local level = config.levels[levelName] or {}
          local position = level[entityName]
          if position then
            buildNonMenu(entityName, entity, world)
            setComponentAttribute(world, "position", entityName, "x",
                                  position[1])
            setComponentAttribute(world, "position", entityName, "y",
                                  position[2])
          end
        else
          buildNonMenu(entityName, entity, world)
        end
      end
    end
  end
end

function M.load(love)
  M.love = love
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

  M.buildState(config, world)

  return world
end

return M
