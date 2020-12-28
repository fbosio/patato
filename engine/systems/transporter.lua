M = {}

function M.drag(dt, velocities, gravitationals, gravity)
  for entity, gravitational in pairs(gravitationals or {}) do
    if gravitational then
      local velocity = velocities[entity]
      velocity.y = velocity.y + gravity*dt
    end
  end
end

function M.move(dt, velocities, positions)
  for entity, velocity in pairs(velocities or {}) do
    local position = positions[entity]
    position.x = position.x + velocity.x*dt
    position.y = position.y + velocity.y*dt
  end
end

return M
