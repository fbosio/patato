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

local function snapToWindow(components, targetEntity)
  local wEntity, isWindow, wBox, wPosition = iter.window()(components)
  if not isWindow then return targetEntity end
  local targetTB = getTranslatedBox(components.position[targetEntity],
                                    components.collisionBox[targetEntity])
  local wTB = getTranslatedBox(wPosition, wBox)
  if not isIncluded(targetTB, wTB) then
    translate.left(wTB, math.min(wTB.left, targetTB.left))
    translate.right(wTB, math.max(wTB.right, targetTB.right))
    translate.top(wTB, math.min(wTB.top, targetTB.top))
    translate.bottom(wTB, math.max(wTB.bottom, targetTB.bottom))
  end
  return wEntity
end

function M.update(components, cameraData)
  if not cameraData then return end

  local _, camera, cameraBox, cameraPos = iter.camera()(components)
  local targetEntity = M.entityTagger.getId(cameraData.target)
  if not camera.enabled or not targetEntity then return end

  targetEntity = snapToWindow(components, targetEntity)
  local entityComponents = buildArguments(targetEntity, components)
  local x, y = cameraData.focus(entityComponents)
  local cameraTB = getTranslatedBox(cameraPos, cameraBox)
  translate.horizontalCenter(cameraTB, x)
  translate.verticalCenter(cameraTB, y)
  local _, isLimiter, limiterBox, limiterPos = iter.limiter()(components)
  if not isLimiter then return end
  
  local limiterTB = getTranslatedBox(limiterPos, limiterBox)
  if not isIncluded(cameraTB, limiterTB) then
    translate.left(cameraTB, math.max(cameraTB.left, limiterTB.left))
    translate.right(cameraTB, math.min(cameraTB.right, limiterTB.right))
    translate.top(cameraTB, math.max(cameraTB.top, limiterTB.top))
    translate.bottom(cameraTB, math.min(cameraTB.bottom, limiterTB.bottom))
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
