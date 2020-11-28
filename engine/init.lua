local tinyyaml = require "engine.tinyyaml"

local M = {}

if love then
  M.getDimensions = love.graphics.getDimensions
else
  M.getDimensions = function ()
    return 0, 0
  end
end

local componentNames = {
  input = "input",
  impulseSpeed = "impulseSpeed",
  position = "position",
  velocity = "velocity"
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

local function copyInputToState(component, entityName)
  local defaultInput = {
    left = "left",
    right = "right",
    up = "up",
    down = "down"
  }
  component = isNull(component) and defaultInput or component
  for action, key in pairs(component) do
    if M.keys[key] then
      setComponentAttribute(componentNames.input, entityName, action, key)
    end
  end
end

local function createDefaults(entityName)
  setComponentAttribute(componentNames.impulseSpeed, entityName, "walk", 400)
  local width, height = M.getDimensions()
  setComponentAttribute(componentNames.position, entityName, "x", width/2)
  setComponentAttribute(componentNames.position, entityName, "y", height/2)
  setComponentAttribute(componentNames.velocity, entityName, "x", 0)
  setComponentAttribute(componentNames.velocity, entityName, "y", 0)
end

local function copyImpulseSpeedToState(component, entityName)
  for impulseName, speed in pairs(component) do
    setComponentAttribute(componentNames.impulseSpeed, entityName, impulseName,
                          speed)
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
          copyInputToState(component, entityName)
          createDefaults(entityName)
        elseif componentName == componentNames.impulseSpeed then
          copyImpulseSpeedToState(component, entityName)
        end
      end
    end
  end
end

function M.load(path)
  local paths = {path, "config.yaml", "config.yml"}
  local read = ""
  for _, p in pairs(paths) do
    local file, msg = io.open(p, "r")
    if file then
      read = file:read("*a")
      file:close()
      break
    end
  end
  M.loadFromString(read)
end

function M.draw()
  for entity, position in pairs((M.gameState or {}).position or {}) do
    love.graphics.points({position.x, position.y})
  end
end

return M
