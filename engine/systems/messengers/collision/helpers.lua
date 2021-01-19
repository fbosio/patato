local helpers = require "engine.systems.helpers"
local getTranslatedBox = helpers.getTranslatedBox
local translate = helpers.translate

local M = {}

function M.mustCollideSides(collideables, collisionBoxes, positions,
                            cb, slopeEntity)
  if not slopeEntity then return true, true end

  -- Decide if collision with boundary sides must be checked.
  local mustCollideLeft = true
  local mustCollideRight = true
  -- Check if the slope is around the collideable.
  local slopeBox = collisionBoxes[slopeEntity]
  local slopePosition = positions[slopeEntity]
  local translatedSlopeBox = getTranslatedBox(slopePosition, slopeBox)
  -- Vertical intersection
  if cb.top >= translatedSlopeBox.top
      and cb.top <= translatedSlopeBox.bottom then
    local slopeAttributes = collideables[slopeEntity]
    local normalPointingUp = slopeAttributes.normalPointingUp
    local rising = slopeAttributes.rising
    -- Horizontal intersection
    mustCollideLeft = ((normalPointingUp and rising)
                       or (not normalPointingUp and not rising))
                      and cb.left < translatedSlopeBox.right
    mustCollideRight = ((normalPointingUp and not rising)
                        or (not normalPointingUp and rising))
                       and cb.right < translatedSlopeBox.left
  end
  return mustCollideLeft, mustCollideRight
end

function M.unblockClimber(climber, gravitational)
  if climber and climber.climbing then
    gravitational.enabled = true
    climber.climbing = false
    climber.trellis = nil
  end
end

M.collide = {
  right = function (dt, sv, sb, cb)
    if sb.top < cb.bottom and sb.bottom > cb.top
        and sb.left >= cb.right and sb.left + sv.x*dt < cb.right then
      sv.x = 0
      translate.left(sb, cb.right)
    end
  end,
  top = function (dt, sv, climber, gravitational, sb, cb)
    if sb.bottom <= cb.top and sb.bottom + sv.y*dt > cb.top
        and sb.left < cb.right and sb.right > cb.left then
      sv.y = 0
      translate.bottom(sb, cb.top)
      M.unblockClimber(climber, gravitational)
    end
  end,
  left = function (dt, sv, sb, cb)
    if sb.top < cb.bottom and sb.bottom > cb.top
        and sb.right <= cb.left and sb.right + sv.x*dt > cb.left then
      sv.x = 0
      translate.right(sb, cb.left)
    end
  end,
  bottom = function (dt, sv, sb, cb)
    if sb.top >= cb.bottom and sb.top + sv.y*dt < cb.bottom
        and sb.left < cb.right and sb.right > cb.left then
      sv.y = 0
      translate.top(sb, cb.bottom)
    end
  end
}

return M
