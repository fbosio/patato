local M = {}

local function setComponentAttribute(result, componentName, entityName,
  attribute, value)
  result.gameState[componentName] = result.gameState[componentName] or {}
  result.gameState[componentName][entityName] =
  result.gameState[componentName][entityName] or {}
  result.gameState[componentName][entityName][attribute] = value
end

local function copyInputToState(result, input, entityName)
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
    if result.keys[virtualKey] then
      setComponentAttribute(result, "input", entityName, actionName,
                            virtualKey)
    end
  end
end

local function createDefaults(result, entityName)
  setComponentAttribute(result, "impulseSpeed", entityName, "walk", 400)
  local width, height = M.love.graphics.getDimensions()
  setComponentAttribute(result, "position", entityName, "x", width/2)
  setComponentAttribute(result, "position", entityName, "y", height/2)
  setComponentAttribute(result, "velocity", entityName, "x", 0)
  setComponentAttribute(result, "velocity", entityName, "y", 0)
end

local function copyImpulseSpeedToState(result, impulseSpeed, entityName)
  for impulseName, speed in pairs(impulseSpeed) do
    setComponentAttribute(result, "impulseSpeed", entityName, impulseName,
                          speed)
  end
end

local function copyMenuToState(result, menu, entityName)
  local menuOptions = {}
  for _, option in ipairs(menu.options) do
    menuOptions[#menuOptions+1] = option
  end
  setComponentAttribute(result, "menu", entityName, "options", menuOptions)
end

local stateBuilders = {
  input = function (result, component, entityName)
    copyInputToState(result, component, entityName)
    createDefaults(result, entityName)
  end,
  impulseSpeed = function (result, component, entityName)
    copyImpulseSpeedToState(result, component, entityName)
  end,
  menu = function (result, component, entityName)
    copyMenuToState(result, component, entityName)
  end
}

local function buildState(config, result)
  result.gameState = {}
  if config.entities then
    for entityName, entity in pairs(config.entities) do
      for componentName, component in pairs(entity) do
        stateBuilders[componentName](result, component, entityName)
      end
    end
  end
end

function M.load(love)
  M.love = love
end

function M.buildWorld(config)
  local result = {}
  
  result.world = config.world or {}
  result.world.gravity = result.world.gravity or 0
  
  result.keys = config.keys or {}
  result.keys.left = result.keys.left or "a"
  result.keys.right = result.keys.right or "d"
  result.keys.up = result.keys.up or "w"
  result.keys.down = result.keys.down or "s"
  
  buildState(config, result)

  return result
end

return M
