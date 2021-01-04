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

function M.update(climbers, trellises, collisionBoxes, positions, velocities,
                  gravitationals)
  for climberEntity, climber in pairs(climbers or {}) do
    local climberBox = collisionBoxes[climberEntity]
    local climberPosition = positions[climberEntity]
    local climberVelocity = velocities[climberEntity]
    local isGravitational = (gravitationals or {})[climberEntity]
    local translatedCB = getTranslatedBox(climberPosition, climberBox)

    local isClimberCollidingWithNoTrellises = true
    for trellisEntity, trellis in pairs(trellises or {}) do
      local trellisBox = collisionBoxes[trellisEntity]
      local trellisPosition = positions[trellisEntity]
      local translatedTB = getTranslatedBox(trellisPosition, trellisBox)

      if areOverlapped(translatedCB, translatedTB) then
        isClimberCollidingWithNoTrellises = false
        if climber.climbing then
          snapClimberToTrellis(translatedCB, translatedTB)
        end
      end
    end

    if isClimberCollidingWithNoTrellises then
      climber.climbing = false
    end
  end
end

return M