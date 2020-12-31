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

local function collideRight(box1, box2, v1, p1, dt)
  if box1.top < box2.bottom and box1.bottom > box2.top
      and box1.left >= box2.right and box1.left + v1.x*dt < box2.right then
    v1.x = 0
    p1.x = box2.right + box1.origin.x
  end
end

local function collideTop(box1, box2, v1, p1, dt)
  if box1.bottom <= box2.top and box1.bottom + v1.y*dt > box2.top
      and box1.left < box2.right and box1.right > box2.left then
    v1.y = 0
    p1.y = box2.top - box1.height + box1.origin.y
  end
end

local function collideLeft(box1, box2, v1, p1, dt)
  if box1.top < box2.bottom and box1.bottom > box2.top
      and box1.right <= box2.left and box1.right + v1.x*dt > box2.left then
    v1.x = 0
    p1.x = box2.left - box1.width + box1.origin.x
  end
end

local function collideBottom(box1, box2, v1, p1, dt)
  if box1.top >= box2.bottom and box1.top + v1.y*dt < box2.bottom
      and box1.left < box2.right and box1.right > box2.left then
    v1.y = 0
    p1.y = box2.bottom + box1.origin.y
  end
end

local function collideRectangleSides(box1, box2, v1, p1, dt)
  collideRight(box1, box2, v1, p1, dt)
  collideTop(box1, box2, v1, p1, dt)
  collideLeft(box1, box2, v1, p1, dt)
  collideBottom(box1, box2, v1, p1, dt)
end

local function collideRectangleCorners(box1, box2, v1, p1, dt)
  -- Avoid box overlapping
  if box1.left < box2.right and box1.right > box2.left then
    -- Top
    if box1.bottom > box2.top and box1.bottom < box2.verticalCenter then
      v1.y = 0
      p1.y = box2.top
    -- Bottom
    elseif box1.top < box2.bottom and box1.top > box2.verticalCenter then
      v1.y = 0
      p1.y = box2.bottom + box1.height
    end
  end
end

local function collideRectangle(box1, box2, v1, p1, dt)
  collideRectangleSides(box1, box2, v1, p1, dt)
  collideRectangleCorners(box1, box2, v1, p1, dt)
end

local function collideUpwardTriangle(m, rising, box1, box2, v1, p1, dt,
                                     slopeEntity, solid)
  collideBottom(box1, box2, v1, p1, dt)
  if rising then
    m = m * (-1)
    collideRight(box1, box2, v1, p1, dt)
    if box1.top < box2.bottom and box1.bottom > box2.bottom
        and box1.right <= box2.left and box1.right + v1.x*dt > box2.left then
      v1.x = 0
      p1.x = box2.left - box1.width + box1.origin.x
    end
  else
    collideLeft(box1, box2, v1, p1, dt)
    if box1.top < box2.bottom and box1.bottom > box2.bottom
        and box1.left >= box2.right and box1.left + v1.x*dt < box2.right then
      v1.x = 0
      p1.x = box2.right + box1.origin.x
    end
  end
  local ySlope = m*(p1.x-box2.horizontalCenter) + box2.verticalCenter
  if p1.x >= box2.left and p1.x <= box2.right and box1.bottom >= box2.top
      and box1.bottom <= box2.bottom then
    if box1.bottom + v1.y*dt >= ySlope then
      v1.y = 0
      p1.y = ySlope
      solid.slope = slopeEntity
    end
  end
end

local function collideDownwardTriangle(m, rising, box1, box2, v1, p1, dt,
                                       slopeEntity, solid)
  collideTop(box1, box2, v1, p1, dt)
  if rising then
    m = m * (-1)
    collideLeft(box1, box2, v1, p1, dt)
    if box1.top < box2.top and box1.bottom > box2.top
        and box1.left >= box2.right and box1.left + v1.x*dt < box2.right then
      v1.x = 0
      p1.x = box2.right + box1.origin.x
    end
  else
    collideRight(box1, box2, v1, p1, dt)
    if box1.top < box2.top and box1.bottom > box2.top
        and box1.right <= box2.left and box1.right + v1.x*dt > box2.left then
      v1.x = 0
      p1.x = box2.left - box1.width + box1.origin.x
    end
  end
  local ySlope = m*(p1.x-box2.horizontalCenter) + box2.verticalCenter
  if p1.x >= box2.left and p1.x <= box2.right and box1.top <= box2.bottom
      and box1.top >= box2.top then
    if box1.top + v1.y*dt <= ySlope then
      v1.y = 0
      p1.y = ySlope + box1.height
      solid.slope = slopeEntity
    end
  end
end

local function collideTriangle(box1, box2, v1, p1, dt, normalPointingUp,
                               rising, slopeEntity, solid)
  local m = box2.height / box2.width
  solid.slope = nil
  if normalPointingUp then
    collideUpwardTriangle(m, rising, box1, box2, v1, p1, dt, slopeEntity,
                          solid)
  else
    collideDownwardTriangle(m, rising, box1, box2, v1, p1, dt, slopeEntity,
                            solid)
  end
end

local function collideCloud(box1, box2, v1, p1, dt)
  collideTop(box1, box2, v1, p1, dt)
end

function M.update(dt, solids, collideables, collisionBoxes, positions,
                  velocities)
  for solidEntity, solid in pairs(solids or {}) do
    local box1 = collisionBoxes[solidEntity]
    local position1 = positions[solidEntity]
    local velocity1 = velocities[solidEntity]
    local translatedBox1 = getTranslatedBox(position1, box1)

    for collideableEntity, collideable in pairs(collideables or {}) do
      local box2 = collisionBoxes[collideableEntity]
      local position2 = positions[collideableEntity]
      local translatedBox2 = getTranslatedBox(position2, box2)

      if box2.height > 0 then
        if collideable.normalPointingUp == nil
            or collideable.rising == nil then
          collideRectangle(translatedBox1, translatedBox2, velocity1,
                           position1, dt)
        else
          collideTriangle(translatedBox1, translatedBox2, velocity1, position1,
                          dt, collideable.normalPointingUp, collideable.rising,
                          collideableEntity, solid)
        end
      else
        collideCloud(translatedBox1, translatedBox2, velocity1, position1, dt)
      end
    end
  end
end

return M
