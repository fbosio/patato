local helpers = require "engine.systems.messengers.helpers"
local getTranslatedBox = helpers.getTranslatedBox
local translate = helpers.translate


local M = {}

--[[
  sb = solid box,
  cb = collideable box,
  sv = solid velocity
]]

local function mustCollideSides(collideables, collisionBoxes, positions,
                                slopeEntity, cb)
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

local function collideRight(sb, cb, sv, dt)
  if sb.top < cb.bottom and sb.bottom > cb.top
      and sb.left >= cb.right and sb.left + sv.x*dt < cb.right then
    sv.x = 0
    translate.left(sb, cb.right)
  end
end

local function collideTop(sb, cb, sv, dt)
  if sb.bottom <= cb.top and sb.bottom + sv.y*dt > cb.top
      and sb.left < cb.right and sb.right > cb.left then
    sv.y = 0
    translate.bottom(sb, cb.top)
  end
end

local function collideLeft(sb, cb, sv, dt)
  if sb.top < cb.bottom and sb.bottom > cb.top
      and sb.right <= cb.left and sb.right + sv.x*dt > cb.left then
    sv.x = 0
    translate.right(sb, cb.left)
  end
end

local function collideBottom(sb, cb, sv, dt)
  if sb.top >= cb.bottom and sb.top + sv.y*dt < cb.bottom
      and sb.left < cb.right and sb.right > cb.left then
    sv.y = 0
    translate.top(sb, cb.bottom)
  end
end

local function collideRectangleSides(mustCollideLeftSide, mustCollideRightSide,
                                     sb, cb, sv, dt)
  if mustCollideLeftSide then
    collideLeft(sb, cb, sv, dt)
  end
  if mustCollideRightSide then
    collideRight(sb, cb, sv, dt)
  end
  collideTop(sb, cb, sv, dt)
  collideBottom(sb, cb, sv, dt)
end

local function collideRectangleCorners(sb, cb, sv)
  -- Avoid box overlapping
  if sb.left < cb.right and sb.right > cb.left then
    -- Top
    if sb.bottom > cb.top and sb.bottom < cb.verticalCenter then
      sv.y = 0
      translate.bottom(sb, cb.top)
    -- Bottom
    elseif sb.top < cb.bottom and sb.top > cb.verticalCenter then
      sv.y = 0
      translate.top(sb, cb.bottom)
    end
  end
end

local function collideRectangle(collideables, collisionBoxes, positions,
                                slope, sb, cb, sv, dt)
  local left, right = mustCollideSides(collideables, collisionBoxes, positions,
                                       slope, cb)
  collideRectangleSides(left, right, sb, cb, sv, dt)
  if left and right then
    collideRectangleCorners(sb, cb, sv)
  end
end

local function collideRightTriangleCorner(sb, cb, sv, dt)
  if (sb.left >= cb.right and sb.left + sv.x*dt < cb.right)
      or (sb.left < cb.right and sb.left > cb.horizontalCenter) then
    sv.x = 0
    translate.left(sb, cb.right)
  end
end

local function collideTopTriangleCorner(sb, cb, sv, dt)
  if sb.bottom >= cb.top and sb.bottom <= cb.bottom then
    translate.bottom(sb, cb.top)
  end
end

local function collideLeftTriangleCorner(sb, cb, sv, dt)
  if (sb.right <= cb.left and sb.right + sv.x*dt > cb.left)
      or (sb.right > cb.left and sb.right < cb.horizontalCenter) then
    sv.x = 0
    translate.right(sb, cb.left)
  end
end

local function collideBottomTriangleCorner(sb, cb, sv, dt)
  if sb.top >= cb.top and sb.top <= cb.bottom then
    translate.top(sb, cb.bottom)
  end
end

local function collideUpwardTriangle(mustCollideLeft, mustCollideRight, m,
                                     rising, sb, cb, sv, dt, slopeEntity,
                                     solid, gravitational)
  collideBottom(sb, cb, sv, dt)
  if rising then
    m = m * (-1)
    if mustCollideRight then
      collideRight(sb, cb, sv, dt)
    end
    if sb.top < cb.bottom and sb.bottom > cb.bottom then
      collideLeftTriangleCorner(sb, cb, sv, dt)
    end
    if sb.left < cb.right and sb.horizontalCenter > cb.right then
      collideTopTriangleCorner(sb, cb, sv, dt)
    end
  else
    if mustCollideLeft then
      collideLeft(sb, cb, sv, dt)
    end
    if sb.top < cb.bottom and sb.bottom > cb.bottom then
      collideRightTriangleCorner(sb, cb, sv, dt)
    end
    if sb.right > cb.left and sb.horizontalCenter < cb.left then
      collideTopTriangleCorner(sb, cb, sv, dt)
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
    if gravitational and sv.x ~= 0 and sv.y == 0 then
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

local function collideDownwardTriangle(mustCollideLeft, mustCollideRight, m,
                                       rising, sb, cb, sv, dt, slopeEntity,
                                       solid)
  collideTop(sb, cb, sv, dt)
  if rising then
    m = m * (-1)
    if mustCollideLeft then
      collideLeft(sb, cb, sv, dt)
    end
    if sb.top < cb.top and sb.bottom > cb.top then
      collideRightTriangleCorner(sb, cb, sv, dt)
    end
    if sb.right > cb.left and sb.horizontalCenter < cb.left then
      collideBottomTriangleCorner(sb, cb, sv, dt)
    end
  else
    if mustCollideRight then
      collideRight(sb, cb, sv, dt)
    end
    if sb.top < cb.top and sb.bottom > cb.top then
      collideLeftTriangleCorner(sb, cb, sv, dt)
    end
    if sb.left < cb.right and sb.horizontalCenter > cb.right then
      collideBottomTriangleCorner(sb, cb, sv, dt)
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

local function collideTriangle(collideables, collisionBoxes, positions,
                               sb, cb, sv, dt, normalPointingUp, rising,
                               slope, solid, gravitational)
  local left, right = mustCollideSides(collideables, collisionBoxes, positions,
                                       solid.slope, cb)
  local m = cb.height / cb.width
  if normalPointingUp then
    collideUpwardTriangle(left, right, m, rising, sb, cb, sv, dt, slope,
                          solid, gravitational)
  else
    collideDownwardTriangle(left, right, m, rising, sb, cb, sv, dt, slope,
                            solid)
  end
end

local function collideCloud(sb, cb, sv, dt)
  collideTop(sb, cb, sv, dt)
end

function M.update(dt, solids, collideables, collisionBoxes, positions,
                  velocities, gravitationals)
  for solidEntity, solid in pairs(solids or {}) do
    local solidBox = collisionBoxes[solidEntity]
    local solidPosition = positions[solidEntity]
    local solidVelocity = velocities[solidEntity]
    gravitationals = gravitationals or {}
    local isGravitational = (gravitationals[solidEntity] or {}).enabled
    local translatedSB = getTranslatedBox(solidPosition, solidBox)

    for collideableEntity, collideable in pairs(collideables or {}) do
      local collideableBox = collisionBoxes[collideableEntity]
      local collideablePosition = positions[collideableEntity]
      local translatedCB = getTranslatedBox(collideablePosition,
                                            collideableBox)

      if collideableBox.height > 0 then
        if collideable.normalPointingUp == nil
            or collideable.rising == nil then
          collideRectangle(collideables, collisionBoxes, positions,
                           solid.slope, translatedSB, translatedCB,
                           solidVelocity, dt)
        else
          collideTriangle(collideables, collisionBoxes, positions,
                          translatedSB, translatedCB, solidVelocity, dt,
                          collideable.normalPointingUp, collideable.rising,
                          collideableEntity, solid, isGravitational)
        end
      else
        collideCloud(translatedSB, translatedCB, solidVelocity, dt)
      end
    end
  end


end

return M
