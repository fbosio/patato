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

local function collideSurfaceX(box1, box2, v1, p1, dt)
  if box1.left >= box2.right and box1.left + v1.x*dt < box2.right then
    v1.x = 0
    p1.x = box2.right + box1.origin.x
  elseif box1.right <= box2.left and box1.right + v1.x*dt > box2.left then
    v1.x = 0
    p1.x = box2.left - box1.width + box1.origin.x
  end
end

local function collideSurfaceY(box1, box2, v1, p1, dt)
  if box1.top >= box2.bottom and box1.top + v1.y*dt < box2.bottom then
    v1.y = 0
    p1.y = box2.bottom + box1.origin.y
  elseif box1.bottom > box2.top and box1.bottom < box2.verticalCenter then
    v1.y = 0
    p1.y = box2.top
  elseif box1.top < box2.bottom and box1.top > box2.verticalCenter then
    v1.y = 0
    p1.y = box2.bottom + box1.height
  end
end

local function collideCloud(box1, box2, v1, p1, dt)
  if box1.bottom <= box2.top and box1.bottom + v1.y*dt > box2.top
      and box1.left < box2.right and box1.right > box2.left then
    v1.y = 0
    p1.y = box2.top - box1.height + box1.origin.y
  end
end

local function collideRectangle(box1, box2, v1, p1, dt)
  if box1.left < box2.right and box1.right > box2.left then
    collideSurfaceY(box1, box2, v1, p1, dt)
  elseif box1.top < box2.bottom and box1.bottom > box2.top then
    collideSurfaceX(box1, box2, v1, p1, dt)
  end
end

local function collideTriangle(normalPointingUp, rising, box1, box2,
                                       v1, p1, dt)
  local m = box2.height / box2.width
  if normalPointingUp then
    if box1.left < box2.right and box1.right > box2.left and box1.top >= box2.bottom and box1.top + v1.y*dt < box2.bottom then
      v1.y = 0
      p1.y = box2.bottom + box1.origin.y
    end
    if rising then
      m = m * (-1)
      if box1.top < box2.bottom and box1.bottom > box2.top and box1.left >= box2.right and box1.left + v1.x*dt < box2.right then
        v1.x = 0
        p1.x = box2.right + box1.origin.x
      end
      if box1.top < box2.bottom and box1.bottom > box2.bottom and box1.right <= box2.left and box1.right + v1.x*dt > box2.left then
        v1.x = 0
        p1.x = box2.left - box1.width + box1.origin.x
      end
    else
      if box1.top < box2.bottom and box1.bottom > box2.bottom and box1.left >= box2.right and box1.left + v1.x*dt < box2.right then
        v1.x = 0
        p1.x = box2.right + box1.origin.x
      end
      if box1.top < box2.bottom and box1.bottom > box2.top and box1.right <= box2.left and box1.right + v1.x*dt > box2.left then
        v1.x = 0
        p1.x = box2.left - box1.width + box1.origin.x
      end
    end
    local ySlope = m*(p1.x-box2.horizontalCenter) + box2.verticalCenter
    if p1.x >= box2.left and p1.x <= box2.right and box1.bottom >= box2.top
        and box1.bottom <= box2.bottom then
      if box1.bottom + v1.y*dt >= ySlope then
        v1.y = 0
        p1.y = ySlope
      end
    end
  else
    if box1.left < box2.right and box1.right > box2.left and box1.bottom <= box2.top and box1.bottom + v1.y*dt > box2.top then
      v1.y = 0
      p1.y = box2.top - box1.height + box1.origin.y
    end
    if rising then
      m = m * (-1)
      if box1.top < box2.top and box1.bottom > box2.top and box1.left >= box2.right and box1.left + v1.x*dt < box2.right then
        v1.x = 0
        p1.x = box2.right + box1.origin.x
      end
      if box1.top < box2.bottom and box1.bottom > box2.top and box1.right <= box2.left and box1.right + v1.x*dt > box2.left then
        v1.x = 0
        p1.x = box2.left - box1.width + box1.origin.x
      end
    else
      if box1.top < box2.bottom and box1.bottom > box2.top and box1.left >= box2.right and box1.left + v1.x*dt < box2.right then
        v1.x = 0
        p1.x = box2.right + box1.origin.x
      end
      if box1.top < box2.top and box1.bottom > box2.top and box1.right <= box2.left and box1.right + v1.x*dt > box2.left then
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
      end
    end
  end
end


function M.update(dt, solids, collideables, collisionBoxes, positions,
                  velocities)
  for solidEntity, _ in pairs(solids or {}) do
    local box1 = collisionBoxes[solidEntity]
    local position1 = positions[solidEntity]
    local velocity1 = velocities[solidEntity]
    local translatedBox1 = getTranslatedBox(position1, box1)

    for collideableEntity, collideable in pairs(collideables or {}) do
      local box2 = collisionBoxes[collideableEntity]
      local position2 = positions[collideableEntity]
      local translatedBox2 = getTranslatedBox(position2, box2)

      if collideable.normalPointingUp == nil or collideable.rising == nil then
        if box2.height > 0 then
            collideRectangle(translatedBox1, translatedBox2, velocity1,
                                     position1, dt)
        end
        collideCloud(translatedBox1, translatedBox2, velocity1,
                            position1, dt)
      else
        collideTriangle(collideable.normalPointingUp,
                                collideable.rising, translatedBox1,
                                translatedBox2, velocity1, position1, dt)
      end
    end
  end
end

return M
