local tinyyaml = require "engine.tinyyaml"

local M = {}

local componentNames = {
  input = "input",
  impulseSpeed = "impulseSpeed",
  position = "position",
  velocity = "velocity"
}

local function isNull(parsedYaml)
  return not parsedYaml or parsedYaml.isnull and parsedYaml.isnull()
end

local function setComponentAttribute(result, componentName, entityName,
                                     attribute, value)
  result.gameState[componentName] = result.gameState[componentName] or {}
  result.gameState[componentName][entityName] =
    result.gameState[componentName][entityName] or {}
  result.gameState[componentName][entityName][attribute] = value
end

local function copyInputToState(result, component, entityName)
  local defaultInput = {
    left = "left",
    right = "right",
    up = "up",
    down = "down"
  }
  component = isNull(component) and defaultInput or component
  for action, key in pairs(component) do
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

function M.loadFromString(configYaml)
  local config = tinyyaml.parse(configYaml) or {}
  local result = {}

  result.gameState = {}

  result.world = isNull(config.world) and {} or config.world
  result.world.gravity = result.world.gravity or 0

  result.keys = isNull(config.keys) and {} or config.keys
  result.keys.left = result.keys.left or "a"
  result.keys.right = result.keys.right or "d"
  result.keys.up = result.keys.up or "w"
  result.keys.down = result.keys.down or "s"

  if not isNull(config.entities) then
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
