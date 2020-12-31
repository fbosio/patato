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
  local mustCheckLeft = true
  local mustCheckRight = true

  -- Verify that the slope is not around.
  local slopeAttributes = collideables[slopeEntity]
  local slopeBox = collisionBoxes[slopeEntity]
  local slopePosition = positions[slopeEntity]
  local translatedSlopeBox = getTranslatedBox(slopePosition, slopeBox)
  if slopeAttributes.normalPointingUp and slopeAttributes.rising
      and cb.top >= translatedSlopeBox.top
      and cb.top <= translatedSlopeBox.bottom then
    mustCheckLeft = cb.left < translatedSlopeBox.right
  end
  if slopeAttributes.normalPointingUp and not slopeAttributes.rising
      and cb.top >= translatedSlopeBox.top
      and cb.top <= translatedSlopeBox.bottom then
    mustCheckRight = cb.right < translatedSlopeBox.left
  end

  return mustCheckLeft, mustCheckRight
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
      sp.y = cb.top
    -- Bottom
    elseif sb.top < cb.bottom and sb.top > cb.verticalCenter then
      sv.y = 0
      sp.y = cb.bottom + sb.height
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

local function collideUpwardTriangle(m, rising, sb, cb, sv, sp, dt,
                                     slopeEntity, solid)
  collideBottom(sb, cb, sv, sp, dt)
  if rising then
    m = m * (-1)
    collideRight(sb, cb, sv, sp, dt)
    if sb.top < cb.bottom and sb.bottom > cb.bottom
        and sb.right <= cb.left and sb.right + sv.x*dt > cb.left then
      sv.x = 0
      sp.x = cb.left - sb.width + sb.origin.x
    end
  else
    collideLeft(sb, cb, sv, sp, dt)
    if sb.top < cb.bottom and sb.bottom > cb.bottom
        and sb.left >= cb.right and sb.left + sv.x*dt < cb.right then
      sv.x = 0
      sp.x = cb.right + sb.origin.x
    end
  end
  local ySlope = m*(sp.x-cb.horizontalCenter) + cb.verticalCenter
  if sp.x >= cb.left and sp.x <= cb.right and sb.bottom >= cb.top
      and sb.bottom <= cb.bottom then
    if sb.bottom + sv.y*dt >= ySlope then
      sv.y = 0
      sp.y = ySlope
      solid.slope = slopeEntity
    end
  end
end

local function collideDownwardTriangle(m, rising, sb, cb, sv, sp, dt,
                                       slopeEntity, solid)
  collideTop(sb, cb, sv, sp, dt)
  if rising then
    m = m * (-1)
    collideLeft(sb, cb, sv, sp, dt)
    if sb.top < cb.top and sb.bottom > cb.top
        and sb.left >= cb.right and sb.left + sv.x*dt < cb.right then
      sv.x = 0
      sp.x = cb.right + sb.origin.x
    end
  else
    collideRight(sb, cb, sv, sp, dt)
    if sb.top < cb.top and sb.bottom > cb.top
        and sb.right <= cb.left and sb.right + sv.x*dt > cb.left then
      sv.x = 0
      sp.x = cb.left - sb.width + sb.origin.x
    end
  end
  local ySlope = m*(sp.x-cb.horizontalCenter) + cb.verticalCenter
  if sp.x >= cb.left and sp.x <= cb.right and sb.top <= cb.bottom
      and sb.top >= cb.top then
    if sb.top + sv.y*dt <= ySlope then
      sv.y = 0
      sp.y = ySlope + sb.height
      solid.slope = slopeEntity
    end
  end
end

local function collideTriangle(sb, cb, sv, sp, dt, normalPointingUp,
                               rising, slopeEntity, solid)
  local m = cb.height / cb.width
  solid.slope = nil
  if normalPointingUp then
    collideUpwardTriangle(m, rising, sb, cb, sv, sp, dt, slopeEntity,
                          solid)
  else
    collideDownwardTriangle(m, rising, sb, cb, sv, sp, dt, slopeEntity,
                            solid)
  end
end

local function collideCloud(sb, cb, sv, sp, dt)
  collideTop(sb, cb, sv, sp, dt)
end

function M.update(dt, solids, collideables, collisionBoxes, positions,
                  velocities)
  for solidEntity, solid in pairs(solids or {}) do
    local solidBox = collisionBoxes[solidEntity]
    local solidPosition = positions[solidEntity]
    local solidVelocity = velocities[solidEntity]
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
          collideTriangle(translatedSB, translatedCB, solidVelocity,
                          solidPosition, dt, collideable.normalPointingUp,
                          collideable.rising, collideableEntity, solid)
        end
      else
        collideCloud(translatedSB, translatedCB, solidVelocity, solidPosition,
                     dt)
      end
    end
  end
end

return M
