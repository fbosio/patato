local dt = 1 / 70
local transporter

before_each(function ()
  transporter = require "engine.systems.transporter"
end)

after_each(function ()
  package.loaded["engine.systems.transporter"] = nil
end)

describe("with empty velocity and position tables", function ()
  it("should keep those tables empty", function ()
    local velocities = {}
    local positions = {}

    transporter.update(dt, velocities, positions)

    assert.are.same(velocities, {})
    assert.are.same(positions, {})
  end)
end)

describe("receiving an entity with nonzero velocity", function ()
  local velocities, positions

  before_each(function ()
    velocities = {
      player = {
        x = 140,
        y = -70
      }
    }
    positions = {
      player = {
        x = -397,
        y = 254
      }
    }
    transporter.update(dt, velocities, positions)
  end)

  it("should update its position", function ()
    assert.are.same({x = -395, y = 253}, positions.player)
  end)

end)

describe("receiving gravity and a gravitational entity", function ()
  it("should upate the velocity of the entity", function ()
    local velocities = {
      anvil = {
        x = 0,
        y = 0
      }
    }
    local positions = {
      anvil = {
        x = 0,
        y = 0
      }
    }
    local gravity = 7000
    local gravitationals = {
      anvil = true
    }
    transporter.update(dt, velocities, positions, gravity, gravitationals)

    assert.are.same(100, velocities.anvil.y)
  end)
end)
