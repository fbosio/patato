local iter = require "engine.iterators"
local helpers = require "engine.systems.helpers"
local buildArguments = helpers.buildArguments
local getTranslatedBox = helpers.getTranslatedBox
local isIncluded = helpers.isIncluded
local translate = helpers.translate

local M = {}

function M.load(love, entityTagger)
  M.love = love
  M.entityTagger = entityTagger
end

function M.update(components, cameraData)
  if cameraData then
    local _, isCamera, cameraBox, cameraPos = iter.camera()(components)
    local targetEntity = M.entityTagger.getId(cameraData.target)
    if isCamera and targetEntity then
      local cameraTB = getTranslatedBox(cameraPos, cameraBox)
      local entityComponents = buildArguments(targetEntity, components)
      local x, y = cameraData.focusCallback(entityComponents)
      translate.horizontalCenter(cameraTB, x)
      translate.verticalCenter(cameraTB, y)
      local _, isLimiter, limiterBox, limiterPos = iter.limiter()(components)
      if isLimiter then
        local limiterTB = getTranslatedBox(limiterPos, limiterBox)
        if not isIncluded(cameraTB, limiterTB) then
          translate.left(cameraTB, math.max(cameraTB.left, limiterTB.left))
          translate.right(cameraTB, math.min(cameraTB.right, limiterTB.right))
          translate.top(cameraTB, math.max(cameraTB.top, limiterTB.top))
          translate.bottom(cameraTB,
                           math.min(cameraTB.bottom, limiterTB.bottom))
        end
      end
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
