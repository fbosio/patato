local M = {}

function M.update(collectors, collectables, collectableEffects,
                  collisionBoxes, positions, garbage)
  for collectorEntity, _ in pairs(collectors or {}) do
    local box1 = collisionBoxes[collectorEntity]
    local position1 = positions[collectorEntity]
    local x1, y1 = position1.x - box1.origin.x, position1.y - box1.origin.y
    
    for collectableEntity, collectable in pairs(collectables or {}) do
      local box2 = collisionBoxes[collectableEntity]
      local position2 = positions[collectableEntity]
      local x2, y2 = position2.x - box2.origin.x, position2.y - box2.origin.y

      local left1 = x1
      local right1 = x1 + box1.width
      local top1 = y1
      local bottom1 = y1 + box1.height
      local left2 = x2
      local right2 = x2 + box2.width
      local top2 = y2
      local bottom2 = y2 + box2.height

      if left1 <= right2 and right1 >= left2 and top1 <= bottom2
          and bottom1 >= top2 then
        collectableEffects[collectable.name]()
        garbage[collectableEntity] = true
      end
    end
  end
end

return M
