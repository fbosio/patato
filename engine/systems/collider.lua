local M = {}

local function getTranslatedBox(position, box)
  local x = position.x - box.origin.x
  local y = position.y - box.origin.y
  return {
    origin = {x = box.origin.x, y = box.origin.y},
    width = box.width,
    height = box.height,
    left = x,
    right = x + box.width,
    top = y,
    bottom = y + box.height,
    horizontalCenter = x + box.width/2,
    verticalCenter = y + box.height/2
  }
end

--[[
  sb = solid box,
  cb = collideable box,
  sv = solid velocity,
  sp = solid position,
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

local function collideRight(sb, cb, sv, sp, dt)
  if sb.top < cb.bottom and sb.bottom > cb.top
      and sb.left >= cb.right and sb.left + sv.x*dt < cb.right then
    sv.x = 0
    sp.x = cb.right + sb.origin.x
  end
end

local function collideTop(sb, cb, sv, sp, dt)
  if sb.bottom <= cb.top and sb.bottom + sv.y*dt > cb.top
      and sb.left < cb.right and sb.right > cb.left then
    sv.y = 0
    sp.y = cb.top - sb.height + sb.origin.y
  end
end

local function collideLeft(sb, cb, sv, sp, dt)
  if sb.top < cb.bottom and sb.bottom > cb.top
      and sb.right <= cb.left and sb.right + sv.x*dt > cb.left then
    sv.x = 0
    sp.x = cb.left - sb.width + sb.origin.x
  end
end

local function collideBottom(sb, cb, sv, sp, dt)
  if sb.top >= cb.bottom and sb.top + sv.y*dt < cb.bottom
      and sb.left < cb.right and sb.right > cb.left then
    sv.y = 0
    sp.y = cb.bottom + sb.origin.y
  end
end

local function collideRectangleSides(mustCollideLeftSide, mustCollideRightSide,
                                     sb, cb, sv, sp, dt)
  if mustCollideLeftSide then
    collideLeft(sb, cb, sv, sp, dt)
  end
  if mustCollideRightSide then
    collideRight(sb, cb, sv, sp, dt)
  end
  collideTop(sb, cb, sv, sp, dt)
  collideBottom(sb, cb, sv, sp, dt)
end

local function collideRectangleCorners(sb, cb, sv, sp)
  -- Avoid box overlapping
  if sb.left < cb.right and sb.right > cb.left then
    -- Top
    if sb.bottom > cb.top and sb.bottom < cb.verticalCenter then
      sv.y = 0
      sp.y = cb.top + sb.origin.y - sb.height
    -- Bottom
    elseif sb.top < cb.bottom and sb.top > cb.verticalCenter then
      sv.y = 0
      sp.y = cb.bottom + sb.origin.y
    end
  end
end

local function collideRectangle(collideables, collisionBoxes, positions,
                                slope, sb, cb, sv, sp, dt)
  local left, right = mustCollideSides(collideables, collisionBoxes, positions,
                                       slope, cb)
  collideRectangleSides(left, right, sb, cb, sv, sp, dt)
  if left and right then
    collideRectangleCorners(sb, cb, sv, sp)
  end
end

local function collideRightTriangleCorner(sb, cb, sv, sp, dt, slopeEntity,
                                          sSlopeEntity)
  if (sb.left >= cb.right and sb.left + sv.x*dt < cb.right)
      or (sb.left < cb.right and sb.left > cb.horizontalCenter) then
    sv.x = 0
    sp.x = cb.right + sb.origin.x
  end
end

local function collideTopTriangleCorner(sb, cb, sv, sp, dt)
  if sb.bottom >= cb.top and sb.bottom <= cb.bottom then
    sp.y = cb.top - sb.height + sb.origin.y
  end
end

local function collideLeftTriangleCorner(sb, cb, sv, sp, dt, slopeEntity,
                                         sSlopeEntity)
  if (sb.right <= cb.left and sb.right + sv.x*dt > cb.left)
      or (sb.right > cb.left and sb.right < cb.horizontalCenter) then
    sv.x = 0
    sp.x = cb.left - sb.width + sb.origin.x
  end
end

local function collideBottomTriangleCorner(sb, cb, sv, sp, dt)
  if sb.top >= cb.top and sb.top <= cb.bottom then
    sp.y = cb.bottom + sb.origin.y
  end
end

local function collideUpwardTriangle(mustCollideLeft, mustCollideRight, m,
                                     rising, sb, cb, sv, sp, dt, slopeEntity,
                                     solid, gravitational)
  collideBottom(sb, cb, sv, sp, dt)
  if rising then
    m = m * (-1)
    if mustCollideRight then
      collideRight(sb, cb, sv, sp, dt)
    end
    if sb.top < cb.bottom and sb.bottom > cb.bottom then
      collideLeftTriangleCorner(sb, cb, sv, sp, dt, slopeEntity, solid.slope)
    end
    if sb.left < cb.right and sb.horizontalCenter > cb.right then
      collideTopTriangleCorner(sb, cb, sv, sp, dt)
    end
  else
    if mustCollideLeft then
      collideLeft(sb, cb, sv, sp, dt)
    end
    if sb.top < cb.bottom and sb.bottom > cb.bottom then
      collideRightTriangleCorner(sb, cb, sv, sp, dt, slopeEntity, solid.slope)
    end
    if sb.right > cb.left and sb.horizontalCenter < cb.left then
      collideTopTriangleCorner(sb, cb, sv, sp, dt)
    end
  end
  if sb.horizontalCenter >= cb.left and sb.horizontalCenter <= cb.right
      and sb.bottom >= cb.top and sb.bottom <= cb.bottom then
    local ySlope = m*(sp.x-cb.horizontalCenter) + cb.verticalCenter
    if sb.bottom + sv.y*dt >= ySlope
        or (sb.bottom == cb.top and sb.right+sv.x*dt > cb.left) then
      sp.y = ySlope - sb.height + sb.origin.y
      sv.y = 0
      solid.slope = slopeEntity
    end
    if gravitational and sv.x ~= 0 and sv.y == 0 then
      local newX = sp.x + sv.x*dt
      if newX <= cb.right and newX >= cb.left then
        local ySlope = m*(newX-cb.horizontalCenter) + cb.verticalCenter
        sp.y = ySlope - sb.height + sb.origin.y
      end
    end
  elseif solid.slope == slopeEntity then
      solid.slope = nil
  end
end

local function collideDownwardTriangle(mustCollideLeft, mustCollideRight, m,
                                       rising, sb, cb, sv, sp, dt, slopeEntity,
                                       solid)
  collideTop(sb, cb, sv, sp, dt)
  if rising then
    m = m * (-1)
    if mustCollideLeft then
      collideLeft(sb, cb, sv, sp, dt)
    end
    if sb.top < cb.top and sb.bottom > cb.top then
      collideRightTriangleCorner(sb, cb, sv, sp, dt, slopeEntity, solid.slope)
    end
    if sb.right > cb.left and sb.horizontalCenter < cb.left then
      collideBottomTriangleCorner(sb, cb, sv, sp, dt)
    end
  else
    if mustCollideRight then
      collideRight(sb, cb, sv, sp, dt)
    end
    if sb.top < cb.top and sb.bottom > cb.top then
      collideLeftTriangleCorner(sb, cb, sv, sp, dt, slopeEntity, solid.slope)
    end
    if sb.left < cb.right and sb.horizontalCenter > cb.right then
      collideBottomTriangleCorner(sb, cb, sv, sp, dt)
    end
  end
  if sb.horizontalCenter >= cb.left and sb.horizontalCenter <= cb.right
      and sb.top <= cb.bottom and sb.top >= cb.top then
    local ySlope = m*(sp.x-cb.horizontalCenter) + cb.verticalCenter
    if sb.top + sv.y*dt <= ySlope then
      sv.y = 0
      sp.y = ySlope + sb.origin.y
      solid.slope = slopeEntity
    end
  elseif solid.slope == slopeEntity then
    solid.slope = nil
  end
end

local function collideTriangle(collideables, collisionBoxes, positions,
                               sb, cb, sv, sp, dt, normalPointingUp, rising,
                               slope, solid, gravitational)
  local left, right = mustCollideSides(collideables, collisionBoxes, positions,
                                       solid.slope, cb)
  local m = cb.height / cb.width
  if normalPointingUp then
    collideUpwardTriangle(left, right, m, rising, sb, cb, sv, sp, dt, slope,
                          solid, gravitational)
  else
    collideDownwardTriangle(left, right, m, rising, sb, cb, sv, sp, dt, slope,
                            solid)
  end
end

local function collideCloud(sb, cb, sv, sp, dt)
  collideTop(sb, cb, sv, sp, dt)
end

function M.update(dt, solids, collideables, collisionBoxes, positions,
                  velocities, gravitationals)
  for solidEntity, solid in pairs(solids or {}) do
    local solidBox = collisionBoxes[solidEntity]
    local solidPosition = positions[solidEntity]
    local solidVelocity = velocities[solidEntity]
    local isGravitational = (gravitationals or {})[solidEntity]
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
                           solidVelocity, solidPosition, dt)
        else
          collideTriangle(collideables, collisionBoxes, positions,
                          translatedSB, translatedCB, solidVelocity,
                          solidPosition, dt, collideable.normalPointingUp,
                          collideable.rising, collideableEntity, solid,
                          isGravitational)
        end
      else
        collideCloud(translatedSB, translatedCB, solidVelocity, solidPosition,
                     dt)
      end
    end
  end
end

return M
