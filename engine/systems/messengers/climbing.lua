local helpers = require "engine.systems.messengers.helpers"
local getTranslatedBox = helpers.getTranslatedBox
local areOverlapped = helpers.areOverlapped
local translate = helpers.translate


local M = {}

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
          translate.left(translatedCB, translatedTB.left)
        end
      end
    end

    if isClimberCollidingWithNoTrellises then
      climber.climbing = false
    end
  end
end

return M