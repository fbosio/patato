local iter = require "engine.iterators"
local helpers = require "engine.systems.helpers"
local buildArguments = helpers.buildArguments
local getTranslatedBox = helpers.getTranslatedBox
local translate = helpers.translate

local M = {}

function M.load(love, entityTagger)
  M.love = love
  M.entityTagger = entityTagger
end

function M.update(components, cameraData)
  if cameraData then
    local _, isCamera, collisionBox, position = iter.camera()(components)
    local targetEntity = M.entityTagger.getId(cameraData.target)
    if isCamera and targetEntity then
      local entityComponents = buildArguments(targetEntity, components)
      local x, y = cameraData.focusCallback(entityComponents)
      local box = getTranslatedBox(position, collisionBox)
      translate.horizontalCenter(box, x)
      translate.verticalCenter(box, y)
    end
  end
end

function M.draw(components, cameraData)
  if cameraData then
    local entity, isCamera, _, position = iter.camera()(components)
    if entity and isCamera then
      M.love.graphics.translate(-position.x, -position.y)
    end
  end
end

return M
