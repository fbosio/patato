local M = {}

function M.load(love, components)
  M.love = love
  M.components = components
end

function M.set(name, entity, value)
  M.components[name] = M.components[name] or {}
  M.components[name][entity] = value
end

function M.setAttribute(name, entity, attribute, value)
  M.components[name] = M.components[name] or {}
  M.components[name][entity] = M.components[name][entity] or {}
  M.components[name][entity][attribute] = value
end

function M.setDefaultPosition(entity)
  local width, height = M.love.graphics.getDimensions()
  M.setAttribute("position", entity, "x", width/2)
  M.setAttribute("position", entity, "y", height/2)
end

local function setDefaultVelocity(entity)
  M.setAttribute("velocity", entity, "x", 0)
  M.setAttribute("velocity", entity, "y", 0)
end

function M.setDefaults(entity)
  M.components.impulseSpeed = M.components.impulseSpeed or {}
  M.components.impulseSpeed[entity] = M.components.impulseSpeed[entity] or {}
  if not M.components.impulseSpeed[entity].walk then
    M.setAttribute("impulseSpeed", entity, "walk", 400)
  end
  M.setDefaultPosition(entity)
  setDefaultVelocity(entity)
end

return M
