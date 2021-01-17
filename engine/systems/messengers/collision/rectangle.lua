local messengersHelpers = require "engine.systems.messengers.helpers"
local collisionHelpers = require "engine.systems.messengers.collision.helpers"
local translate = messengersHelpers.translate
local mustCollideSides = collisionHelpers.mustCollideSides
local unblockClimber = collisionHelpers.unblockClimber
local collide = collisionHelpers.collide


local M = {}

local function collideSides(dt, sv, climber, gravitational, sb, cb,
                            mustCollideLeft, mustCollideRight)
  if mustCollideLeft then
    collide.left(dt, sv, sb, cb)
  end
  if mustCollideRight then
    collide.right(dt, sv, sb, cb)
  end
  collide.top(dt, sv, climber, gravitational, sb, cb)
  collide.bottom(dt, sv, sb, cb)
end

local function collideCorners(sv, climber, gravitational, sb, cb)
  -- Avoid box overlapping
  if sb.left < cb.right and sb.right > cb.left then
    -- Top
    if sb.bottom > cb.top and sb.bottom < cb.verticalCenter then
      sv.y = 0
      translate.bottom(sb, cb.top)
      unblockClimber(climber, gravitational)
    -- Bottom
    elseif sb.top < cb.bottom and sb.top > cb.verticalCenter then
      sv.y = 0
      translate.top(sb, cb.bottom)
    end
  end
end

function M.update(dt, collideables, collisionBoxes, positions,
                  sv, climber, gravitational, sb, cb, slope)
  local left, right = mustCollideSides(collideables, collisionBoxes, positions,
                                       cb, slope)
  collideSides(dt, sv, climber, gravitational, sb, cb, left, right)
  if left and right then
    collideCorners(sv, climber, gravitational, sb, cb)
  end
end

return M
