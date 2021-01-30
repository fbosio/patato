local iter = require "engine.iterators"

M = {}

function M.drag(dt, components, gravity)
  for _, gravitational, velocity in iter.gravitational(components) do
    if gravitational.enabled then
      velocity.y = velocity.y + gravity*dt
    end
  end
end

function M.move(dt, components)
  for _, velocity, position in iter.velocity(components) do
    if velocity.enabled then
      position.x = position.x + velocity.x*dt
      position.y = position.y + velocity.y*dt
    end
  end
end

return M
