local M = {}

local componentNames = {
  input = "input",
  impulseSpeed = "impulseSpeed",
  position = "position",
  velocity = "velocity"
}

local function setComponentAttribute(result, componentName, entityName,
                                     attribute, value)
  result.gameState[componentName] = result.gameState[componentName] or {}
  result.gameState[componentName][entityName] =
    result.gameState[componentName][entityName] or {}
  result.gameState[componentName][entityName][attribute] = value
end

local function copyInputToState(result, input, entityName)
  local defaultInput = {
    left = "left",
    right = "right",
    up = "up",
    down = "down"
  }
  for action, defaultKey in pairs(defaultInput) do
    input[action] = input[action] or defaultKey
  end
  for action, key in pairs(input) do
    if result.keys[key] then
      setComponentAttribute(result, componentNames.input, entityName, action,
                            key)
    end
  end
end

local function createDefaults(result, entityName)
  setComponentAttribute(result, componentNames.impulseSpeed, entityName,
                        "walk", 400)
  local width, height = M.love.graphics.getDimensions()
  setComponentAttribute(result, componentNames.position, entityName,
                        "x", width/2)
  setComponentAttribute(result, componentNames.position, entityName,
                        "y", height/2)
  setComponentAttribute(result, componentNames.velocity, entityName,
                        "x", 0)
  setComponentAttribute(result, componentNames.velocity, entityName,
                        "y", 0)
end

local function copyImpulseSpeedToState(result, component, entityName)
  for impulseName, speed in pairs(component) do
    setComponentAttribute(result, componentNames.impulseSpeed, entityName,
                          impulseName, speed)
  end
end

function M.init(love)
  M.love = love
end

function M.loadFromTable(config)
  -- local config = tinyyaml.parse(configYaml) or {}
  local result = {}

  result.gameState = {}

  result.world = config.world or {}
  result.world.gravity = result.world.gravity or 0

  result.keys = config.keys or {}
  result.keys.left = result.keys.left or "a"
  result.keys.right = result.keys.right or "d"
  result.keys.up = result.keys.up or "w"
  result.keys.down = result.keys.down or "s"

  if config.entities then
    for entityName, entity in pairs(config.entities) do
      for componentName, component in pairs(entity) do
        if componentName == componentNames.input then
          copyInputToState(result, component, entityName)
          createDefaults(result, entityName)
        elseif componentName == componentNames.impulseSpeed then
          copyImpulseSpeedToState(result, component, entityName)
        end
      end
    end
  end

  return result
end

return M
