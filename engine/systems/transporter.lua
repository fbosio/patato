M = {}

function M.update(dt, velocities, positions, collisionBoxes)
  for entity, velocity in pairs(velocities or {}) do
    local position = positions[entity]
    position.x = position.x + velocity.x*dt
    position.y = position.y + velocity.y*dt
  end

  for entity, collisionBox in pairs(collisionBoxes or {}) do
    local position = positions[entity]
    collisionBox.x = position.x - collisionBox.origin.x
    collisionBox.y = position.y - collisionBox.origin.y
  end
end

return M
