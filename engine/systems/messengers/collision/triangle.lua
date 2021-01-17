local messengersHelpers = require "engine.systems.messengers.helpers"
local collisionHelpers = require "engine.systems.messengers.collision.helpers"
local translate = messengersHelpers.translate
local mustCollideSides = collisionHelpers.mustCollideSides
local collide = collisionHelpers.collide


local M = {}

local function collideRightCorner(dt, sv, sb, cb)
  if (sb.left >= cb.right and sb.left + sv.x*dt < cb.right)
      or (sb.left < cb.right and sb.left > cb.horizontalCenter) then
    sv.x = 0
    translate.left(sb, cb.right)
  end
end

local function collideTopCorner(dt, sv, sb, cb)
  if sb.bottom >= cb.top and sb.bottom <= cb.bottom then
    translate.bottom(sb, cb.top)
  end
end

local function collideLeftCorner(dt, sv, sb, cb)
  if (sb.right <= cb.left and sb.right + sv.x*dt > cb.left)
      or (sb.right > cb.left and sb.right < cb.horizontalCenter) then
    sv.x = 0
    translate.right(sb, cb.left)
  end
end

local function collideBottomCorner(dt, sv, sb, cb)
  if sb.top >= cb.top and sb.top <= cb.bottom then
    translate.top(sb, cb.bottom)
  end
end

local function collideUpward(dt, sv, solid, gravitational, sb, cb,
                             slopeEntity, mustCollideLeft, mustCollideRight,
                             m, rising)
  collide.bottom(dt, sv, sb, cb)
  if rising then
    m = m * (-1)
    if mustCollideRight then
      collide.right(dt, sv, sb, cb)
    end
    if sb.top < cb.bottom and sb.bottom > cb.bottom then
      collideLeftCorner(dt, sv, sb, cb)
    end
    if sb.left < cb.right and sb.horizontalCenter > cb.right then
      collideTopCorner(dt, sv, sb, cb)
    end
  else
    if mustCollideLeft then
      collide.left(dt, sv, sb, cb)
    end
    if sb.top < cb.bottom and sb.bottom > cb.bottom then
      collideRightCorner(dt, sv, sb, cb)
    end
    if sb.right > cb.left and sb.horizontalCenter < cb.left then
      collideTopCorner(dt, sv, sb, cb)
    end
  end
  if sb.horizontalCenter >= cb.left and sb.horizontalCenter <= cb.right
      and sb.bottom >= cb.top and sb.bottom <= cb.bottom then
    local ySlope = m*(sb.position.x-cb.horizontalCenter) + cb.verticalCenter
    if sb.bottom + sv.y*dt >= ySlope
        or (sb.bottom == cb.top and sb.right+sv.x*dt > cb.left) then
      sv.y = 0
      translate.bottom(sb, ySlope)
      solid.slope = slopeEntity
    end
    if gravitational.enabled and sv.x ~= 0 and sv.y == 0 then
      local newX = sb.position.x + sv.x*dt
      if newX <= cb.right and newX >= cb.left then
        local ySlope = m*(newX-cb.horizontalCenter) + cb.verticalCenter
        translate.bottom(sb, ySlope)
      end
    end
  elseif solid.slope == slopeEntity then
    solid.slope = nil
  end
end

local function collideDownward(dt, sv, solid, gravitational, climber, sb, cb,
                               slopeEntity, mustCollideLeft, mustCollideRight,
                               m, rising)
  collide.top(dt, sv, climber, gravitational, sb, cb)
  if rising then
    m = m * (-1)
    if mustCollideLeft then
      collide.left(dt, sv, sb, cb)
    end
    if sb.top < cb.top and sb.bottom > cb.top then
      collideRightCorner(dt, sv, sb, cb)
    end
    if sb.right > cb.left and sb.horizontalCenter < cb.left then
      collideBottomCorner(dt, sv, sb, cb)
    end
  else
    if mustCollideRight then
      collide.right(dt, sv, sb, cb)
    end
    if sb.top < cb.top and sb.bottom > cb.top then
      collideLeftCorner(dt, sv, sb, cb)
    end
    if sb.left < cb.right and sb.horizontalCenter > cb.right then
      collideBottomCorner(dt, sv, sb, cb)
    end
  end
  if sb.horizontalCenter >= cb.left and sb.horizontalCenter <= cb.right
      and sb.top <= cb.bottom and sb.top >= cb.top then
    local ySlope = m*(sb.position.x-cb.horizontalCenter) + cb.verticalCenter
    if sb.top + sv.y*dt <= ySlope then
      sv.y = 0
      translate.top(sb, ySlope)
      solid.slope = slopeEntity
    end
  elseif solid.slope == slopeEntity then
    solid.slope = nil
  end
end

function M.update(dt, collideables, collisionBoxes, positions, sv,
                  collideable, solid, climber, gravitational, sb, cb, slope)
  local left, right = mustCollideSides(collideables, collisionBoxes, positions,
                                       cb, solid.slope)
  local m = cb.height / cb.width
  if collideable.normalPointingUp then
    collideUpward(dt, sv, solid, gravitational, sb, cb, slope, left, right, m,
                  collideable.rising)
  else
    collideDownward(dt, sv, solid, gravitational, climber, sb, cb, slope,
                    left, right, m, collideable.rising)
  end
end

return M
