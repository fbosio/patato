local components = require "components"


local M = {}


function M.gravity(state, dt)
  local gravity = 5000
  for entity, weight in pairs(state.weights or {}) do
    local velocities = state.velocities or {}
    local velocity = velocities[entity]
    if velocity then
      velocity.y = velocity.y + gravity*dt
    end
  end
end


function M.movement(state, dt)
  -- components.assertDependency(state, "velocities", "positions")
  for entity, velocity in pairs(state.velocities or {}) do
    local position = state.positions[entity]
    local winWidth, winHeight = love.window.getMode()
    -- components.assertExistence(entity, "velocity", {position, "position"})
    position.x = position.x + velocity.x*dt
    position.y = position.y + velocity.y*dt
  end
end


return M
