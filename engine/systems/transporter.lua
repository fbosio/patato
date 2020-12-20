M = {}

function M.update(dt, velocities, positions, collisionBoxes)
  for entity, velocity in pairs(velocities or {}) do
    local position = positions[entity]
    position.x = position.x + velocity.x*dt
    position.y = position.y + velocity.y*dt
  end

  for entity, collisionBox in pairs(collisionBoxes or {}) do
    local position = positions[entity]
    collisionBox.x = collisionBox.origin.x + position.x
    collisionBox.y = collisionBox.origin.y + position.y
  end
end

return M
