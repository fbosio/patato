local helpers = require "engine.systems.helpers"
local buildArguments = helpers.buildArguments

local M = {}

function M.load(love, entityTagger)
  M.love = love
  M.entityTagger = entityTagger
  M.position = {x = 0, y = 0}
  M.focusCallback = function (t)
    return t.position.x, t.position.y
  end
end

function M.update(components)
  local entity = M.entityTagger.getId(M.target)
  if entity then
    local width, height = M.love.graphics.getDimensions()
    local entityComponents = buildArguments(entity, components)
    local x, y = M.focusCallback(entityComponents)
    M.position.x, M.position.y = width/2 - x, height/2 - y 
  end
end

function M.draw()
  M.love.graphics.translate(M.position.x, M.position.y)
end

function M.setTarget(entityName, focusCallback)
  M.target = entityName
  M.focusCallback = focusCallback
end

return M
