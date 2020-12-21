local dt = 1 / 70
local transporter

before_each(function ()
  transporter = require "engine.systems.transporter"
end)

after_each(function ()
  package.loaded["engine.systems.transporter"] = nil
end)

describe("with empty velocity, position and collision box tables", function ()
  it("should keep those tables empty", function ()
    local velocities = {}
    local positions = {}
    local collisionBoxes = {}

    transporter.update(dt, velocities, positions, collisionBoxes)

    assert.are.same(velocities, {})
    assert.are.same(positions, {})
    assert.are.same(collisionBoxes, {})
  end)
end)

describe("receiving an entity with nonzero velocity", function ()
  local velocities, positions, collisionBoxes

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
    collisionBoxes = {
      player = {
        origin = {
          x = 16,
          y = 64
        },
        x = 0,
        y = 0,
        width = 32,
        height = 64
      }
    }
    transporter.update(dt, velocities, positions, collisionBoxes)
  end)

  it("should update its position", function ()
    assert.are.same({x=-395, y=253}, positions.player)
  end)

  it("should update its collision box", function ()
    assert.are.same(-411, collisionBoxes.player.x)
    assert.are.same(189, collisionBoxes.player.y)
  end)
end)
