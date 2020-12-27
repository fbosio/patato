local dt = 1 / 70
local collider

before_each(function ()
  collider = require "engine.systems.collider"
end)

after_each(function ()
  package.loaded["engine.systems.collider"] = nil
end)

describe("loading a player that collides with a block", function ()
  it("should stop the player so it does not go through the block", function ()
    local solids = {
      mario = true
    }
    local collideables = {
      block = {name = "block"}
    }
    local collisionBoxes = {
      mario = {
        origin = {x = 16, y = 64},
        width = 32,
        height = 64
      },
      block = {
        origin = {x = 16, y = 32},
        width = 32,
        height = 64
      }
    }
    local positions = {
      mario = {
        x = 280,
        y = 380
      },
      block = {
        x = 316,
        y = 380
      }
    }
    local velocities = {
      mario = {
        x = 1400,
        y = 0
      }
    }

    collider.update(dt, solids, collideables, collisionBoxes, positions,
                    velocities)

    assert.are.same(284, positions.mario.x)
    assert.are.same(0, velocities.mario.x)
  end)
end)
