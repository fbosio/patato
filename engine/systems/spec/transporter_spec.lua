local dt = 1 / 70
local transporter

before_each(function ()
  transporter = require "engine.systems.transporter"
end)

after_each(function ()
  package.loaded.transporter = nil
end)

describe("Use empty velocity and position tables", function ()
  it("should keep those tables empty", function ()
    local velocities = {}
    local positions = {}

    transporter.update(dt, velocities, positions)

    assert.are.same(velocities, {})
    assert.are.same(positions, {})
  end)
end)

describe("With nonzero velocity", function ()
  it("should update the position", function ()
    local velocities = {
      player = {
        x = 140,
        y = -70
      }
    }
    local positions = {
      player = {
        x = -397,
        y = 254
      }
    }

    transporter.update(dt, velocities, positions)

    assert.are.same(positions.player, {x=-395, y=253})
  end)
end)
