local dt = 1 / 70
local collider
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

before_each(function ()
  collider = require "engine.systems.collider"
end)

after_each(function ()
  package.loaded["engine.systems.collider"] = nil
end)

describe("with a player touching the left side of a block", function ()
  it("should stop the player and push it to the left", function ()
    local positions = {
      mario = {
        x = 280,
        y = 380
      },
      block = {
        x = 320,
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

    assert.are.same(288, positions.mario.x)
    assert.are.same(0, velocities.mario.x)
  end)
end)

describe("with a player touching the right side of a block", function ()
  it("should stop the player and push it to the right", function ()
    local positions = {
      mario = {
        x = 366,
        y = 380
      },
      block = {
        x = 320,
        y = 380
      }
    }
    local velocities = {
      mario = {
        x = -1400,
        y = 0
      }
    }

    collider.update(dt, solids, collideables, collisionBoxes, positions,
                    velocities)

    assert.are.same(352, positions.mario.x)
    assert.are.same(0, velocities.mario.x)
  end)
end)

describe("with a player touching the bottom of a block", function ()
  it("should stop the player and push it to the bottom", function ()
    local positions = {
      mario = {
        x = 346,
        y = 486
      },
      block = {
        x = 320,
        y = 380
      }
    }
    local velocities = {
      mario = {
        x = 0,
        y = -1400
      }
    }

    collider.update(dt, solids, collideables, collisionBoxes, positions,
                    velocities)

    assert.are.same(476, positions.mario.y)
    assert.are.same(0, velocities.mario.y)
  end)
end)

describe("with a player touching the top of a block", function ()
  it("should stop the player and push it to the top", function ()
    local positions = {
      mario = {
        x = 346,
        y = 338
      },
      block = {
        x = 320,
        y = 380
      }
    }
    local velocities = {
      mario = {
        x = 0,
        y = 1400
      }
    }

    collider.update(dt, solids, collideables, collisionBoxes, positions,
                    velocities)

    assert.are.same(348, positions.mario.y)
    assert.are.same(0, velocities.mario.y)
  end)
end)
