local helpers = require "engine.systems.messengers.helpers"
local getTranslatedBox = helpers.getTranslatedBox
local areOverlapped = helpers.areOverlapped
local translate = helpers.translate


local M = {}

--[[
  cb = climber box,
  tb = trellis box,
]]

local function snapClimberToTrellis(cb, tb)
  if cb.left < tb.left then
    translate.left(cb, tb.left)
  end
  if cb.right > tb.right then
    translate.right(cb, tb.right)
  end
  if cb.top < tb.top then
    translate.top(cb, tb.top)
  end
end

local function stopClimber(dt, cb, tb, cv)
  if cb.left >= tb.left and cb.left + cv.x*dt < tb.left then
    cv.x = 0
    translate.left(cb, tb.left)
  end
  if cb.right <= tb.right and cb.right + cv.x*dt > tb.right then
    cv.x = 0
    translate.right(cb, tb.right)
  end
  if cb.top >= tb.top and cb.top + cv.y*dt < tb.top then
    cv.y = 0
    translate.top(cb, tb.top)
  end
end

function M.update(dt, climbers, trellises, collisionBoxes, positions,
                  velocities, gravitationals)
  for climberEntity, climber in pairs(climbers or {}) do
    local climberBox = collisionBoxes[climberEntity]
    local climberPosition = positions[climberEntity]
    local climberVelocity = velocities[climberEntity]
    local translatedCB = getTranslatedBox(climberPosition, climberBox)
    local gravitationals = gravitationals or {}

    local isClimberCollidingWithNoTrellises = true
    for trellisEntity, trellis in pairs(trellises or {}) do
      local trellisBox = collisionBoxes[trellisEntity]
      local trellisPosition = positions[trellisEntity]
      local translatedTB = getTranslatedBox(trellisPosition, trellisBox)

      if areOverlapped(translatedCB, translatedTB) then
        isClimberCollidingWithNoTrellises = false
        if climber.climbing then
          snapClimberToTrellis(translatedCB, translatedTB)
          stopClimber(dt, translatedCB, translatedTB, climberVelocity)
        end
      end
    end

    if isClimberCollidingWithNoTrellises then
      climber.climbing = false
    end
  end
end

return M
