local rectangle = require "engine.systems.messengers.collision.rectangle"
local helpers = require "engine.systems.messengers.helpers"
local triangle = require "engine.systems.messengers.collision.triangle"
local cloud = require "engine.systems.messengers.collision.cloud"
local getTranslatedBox = helpers.getTranslatedBox
local translate = helpers.translate


local M = {}

function M.update(dt, solids, collideables, collisionBoxes, positions,
                  velocities, gravitationals, climbers)
  for solidEntity, solid in pairs(solids or {}) do
    local solidBox = collisionBoxes[solidEntity]
    local solidPosition = positions[solidEntity]
    local solidVelocity = velocities[solidEntity]
    gravitationals = gravitationals or {}
    local gravitational = gravitationals[solidEntity] or {}
    local climber = (climbers or {})[solidEntity]
    local translatedSB = getTranslatedBox(solidPosition, solidBox)

    for collideableEntity, collideable in pairs(collideables or {}) do
      local collideableBox = collisionBoxes[collideableEntity]
      local collideablePosition = positions[collideableEntity]
      local translatedCB = getTranslatedBox(collideablePosition,
                                            collideableBox)

      if collideableBox.height > 0 then
        if collideable.normalPointingUp == nil
            or collideable.rising == nil then
          rectangle.update(dt, collideables, collisionBoxes, positions,
                           solidVelocity, climber, gravitational,
                           translatedSB, translatedCB, solid.slope)
        else
          triangle.update(dt, collideables, collisionBoxes, positions,
                          solidVelocity, collideable, solid, climber,
                          gravitational, translatedSB, translatedCB, 
                          collideableEntity)
        end
      else
        cloud.update(dt, solidVelocity, climber, gravitational, translatedSB,
                     translatedCB)
      end
    end
  end
end

return M
