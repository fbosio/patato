local M = {}

local function setComponentAttribute(world, componentName, entityName,
  attribute, value)
  world.gameState[componentName] = world.gameState[componentName] or {}
  world.gameState[componentName][entityName] =
  world.gameState[componentName][entityName] or {}
  world.gameState[componentName][entityName][attribute] = value
end

local function copyInputToState(world, input, entityName)
  local defaultInput = {
    walkLeft = "left",
    walkRight = "right",
    walkUp = "up",
    walkDown = "down"
  }
  if not next(input) then  -- check that input (non-boolean) is an empty table
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

local function copyImpulseSpeedToState(world, impulseSpeed, entityName)
  for impulseName, speed in pairs(impulseSpeed) do
    setComponentAttribute(world, "impulseSpeed", entityName, impulseName,
                          speed)
  end
end

local function copyMenuToState(world, menu, entityName)
  local menuOptions = {}
  for _, option in ipairs(menu.options) do
    menuOptions[#menuOptions+1] = option
  end
  setComponentAttribute(world, "menu", entityName, "options", menuOptions)
end

local stateBuilders = {
  input = function (world, component, entityName)
    copyInputToState(world, component, entityName)
    createDefaults(world, entityName)
  end,
  impulseSpeed = function (world, component, entityName)
    copyImpulseSpeedToState(world, component, entityName)
  end,
}

local function buildState(config, world)
  world.gameState = {}
  if config.entities then
    local foundMenu = false
    for entityName, entity in pairs(config.entities) do
      for componentName, component in pairs(entity) do
        if componentName == "menu" then
          copyMenuToState(world, component, entityName)
          foundMenu = true
        end
      end
    end

    if not foundMenu then
      for entityName, entity in pairs(config.entities) do
        for componentName, component in pairs(entity) do
          stateBuilders[componentName](world, component, entityName)
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

  buildState(config, world)

  return world
end

return M
