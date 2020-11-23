local tinyyaml = require "tinyyaml"

local M = {}

local componentNames = {
  input = "input",
  impulseSpeed = "impulseSpeed"
}

local function isNull(parsedYaml)
  return not parsedYaml or parsedYaml.isnull and parsedYaml.isnull()
end

local function setComponentAttribute(componentName, entityName, attribute,
                                     value)
  M.gameState = M.gameState or {}
  M.gameState[componentName] = M.gameState[componentName] or {}
  M.gameState[componentName][entityName] =
   M.gameState[componentName][entityName] or {}
  M.gameState[componentName][entityName][attribute] = value
end

local function copyInputToState(component, componentName, entityName)
  local defaultInput = {
    left = "left",
    right = "right",
    up = "up",
    down = "down"
  }
  component = isNull(component) and defaultInput or component
  for action, key in pairs(component) do
    if M.keys[key] then
      setComponentAttribute(componentName, entityName, action, key)
    end
  end
end

local function createDefaultImpulseSpeed(componentName, entityName)
  setComponentAttribute(componentName, entityName, "walk", 400)
end

local function copyImpulseSpeedToState(component, componentName, entityName)
  for impulseName, speed in pairs(component) do
    setComponentAttribute(componentName, entityName, impulseName, speed)
  end
end

function M.loadFromString(configYaml)
  local config = #configYaml > 0 and tinyyaml.parse(configYaml) or {}

  M.world = isNull(config.world) and {} or config.world
  M.world.gravity = M.world.gravity or 0

  M.keys = isNull(config.keys) and {} or config.keys
  M.keys.left = M.keys.left or "a"
  M.keys.right = M.keys.right or "d"
  M.keys.up = M.keys.up or "w"
  M.keys.down = M.keys.down or "s"

  if not isNull(config.entities) then
    for entityName, entity in pairs(config.entities) do
      for componentName, component in pairs(entity) do
        if componentName == componentNames.input then
          copyInputToState(component, componentName, entityName)
          createDefaultImpulseSpeed(componentNames.impulseSpeed, entityName)
        elseif componentName == componentNames.impulseSpeed then
          copyImpulseSpeedToState(component, componentName, entityName)
        end
      end
    end
  end
end

return M
