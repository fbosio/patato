M = {}

function M.update(dt, velocities, positions, gravity, gravitationals)
  for entity, velocity in pairs(velocities or {}) do
    if (gravitationals or {})[entity] then
      velocity.y = velocity.y + gravity*dt
    end

    local position = positions[entity]
    position.x = position.x + velocity.x*dt
    position.y = position.y + velocity.y*dt
  end
end

return M
