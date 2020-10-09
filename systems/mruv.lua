local components = require "components"
local M = {}



function M.gravity(componentsTable, dt)
  local gravity = 5000

  for entity, weight in pairs(componentsTable.weights or {}) do
    local velocities = componentsTable.velocities or {}
    local velocity = velocities[entity]
    if velocity then
      velocity.y = velocity.y + gravity*dt
    end
  end
end


function M.movement(componentsTable, dt)

  -- components.assertDependency(componentsTable, "velocities", "positions")

  for entity, velocity in pairs(componentsTable.velocities or {}) do
    local position = componentsTable.positions[entity]
    local winWidth, winHeight = love.window.getMode()
    -- components.assertExistence(entity, "velocity", {position, "position"})

    position.x = position.x + velocity.x*dt
    position.y = position.y + velocity.y*dt
  end
end

return M
