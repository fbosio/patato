local M = {}

local function checkRectangleCollisions(x1, y1, x2, y2, box1, box2, velocity1,
                                        position1, dt)
  local left1 = x1
  local right1 = x1 + box1.width
  local top1 = y1
  local bottom1 = y1 + box1.height
  local left2 = x2
  local right2 = x2 + box2.width
  local top2 = y2
  local verticalCenter2 = y2 + box2.height/2
  local bottom2 = y2 + box2.height

  local newVelocity1 = {
    x = velocity1.x,
    y = velocity1.y
  }
  if box2.height > 0 then  -- not a cloud
    if left1 < right2 and right1 > left2 then
      if top1 >= bottom2 and top1 + velocity1.y*dt < bottom2 then
        velocity1.y = 0
        position1.y = bottom2 + box1.origin.y
      elseif bottom1 > top2 and bottom1 < verticalCenter2 then
        velocity1.y = 0
        position1.y = top2
      elseif top1 < bottom2 and top1 > verticalCenter2 then
        velocity1.y = 0
        position1.y = bottom2 + box1.height
      end
    elseif top1 < bottom2 and bottom1 > top2 then
      if left1 >= right2 and left1 + velocity1.x*dt < right2 then
        velocity1.x = 0
        position1.x = right2 + box1.origin.x
      elseif right1 <= left2 and right1 + velocity1.x*dt > left2 then
        velocity1.x = 0
        position1.x = left2 - box1.width + box1.origin.x
      end
    end
  end
  if bottom1 <= top2 and bottom1 + velocity1.y*dt > top2
      and left1 < right2 and right1 > left2 then
    velocity1.y = 0
    position1.y = top2 - box1.height + box1.origin.y
  end
end

function M.update(dt, solids, collideables, collisionBoxes, positions,
                  velocities)
  for solidEntity, _ in pairs(solids or {}) do
    local box1 = collisionBoxes[solidEntity]
    local position1 = positions[solidEntity]
    local velocity1 = velocities[solidEntity]
    local x1, y1 = position1.x - box1.origin.x, position1.y - box1.origin.y

    for collideableEntity, _ in pairs(collideables or {}) do
      local box2 = collisionBoxes[collideableEntity]
      local position2 = positions[collideableEntity]
      local x2, y2 = position2.x - box2.origin.x, position2.y - box2.origin.y

      checkRectangleCollisions(x1, y1, x2, y2, box1, box2, velocity1,
                               position1, dt)
    end
  end
end

return M
