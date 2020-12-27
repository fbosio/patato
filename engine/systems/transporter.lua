M = {}

function M.update(dt, velocities, positions, collisionBoxes)
  for entity, velocity in pairs(velocities or {}) do
    local position = positions[entity]
    position.x = position.x + velocity.x*dt
    position.y = position.y + velocity.y*dt
  end
end

return M
