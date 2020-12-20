local M = {}

function M.update(collectors, collectables, collisionBoxes, garbage)
  for collectorEntity, _ in pairs(collectors or {}) do
    for collectableEntity, _ in pairs(collectables or {}) do
      local box1 = collisionBoxes[collectorEntity]
      local box2 = collisionBoxes[collectableEntity]

      -- Super Hadron Collider
      local left1 = box1.x - box1.origin.x
      local right1 = box1.x - box1.origin.x + box1.width
      local top1 = box1.y - box1.origin.y
      local bottom1 = box1.y - box1.origin.y + box1.height
      local left2 = box2.x - box2.origin.x
      local right2 = box2.x - box2.origin.x + box2.width
      local top2 = box2.y - box2.origin.y
      local bottom2 = box2.y - box2.origin.y + box2.height
      -- function M.Box:intersects(box)
      --   return self:left() <= box:right() and self:right() >= box:left()
      --           and self:top() <= box:bottom() and self:bottom() >= box:top()
      -- end
      if left1 <= right2 and right1 >= left2 and top1 <= bottom2
          and bottom1 >= top2 then
        garbage[collectableEntity] = true
      end
    end
  end
end

return M
