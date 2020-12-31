local dt = 1 / 70
local collider, solids, collisionBoxes

before_each(function ()
  collider = require "engine.systems.collider"
  solids = {
    mario = {}
  }
  collisionBoxes = {
    mario = {
      origin = {x = 16, y = 64},
      width = 32,
      height = 64
    },
    block = {
      origin = {x = 16, y = 32},
      width = 32,
      height = 64
    },
    cloud = {
      origin = {x = 16, y = 0},
      width = 32,
      height = 0
    },
    slope = {
      origin = {x = 16, y = 32},
      width = 32,
      height = 64
    },
  }
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
    local collideables = {
      block = {name = "block"}
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
    local collideables = {
      block = {name = "block"}
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
    local collideables = {
      block = {name = "block"}
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
    local collideables = {
      block = {name = "block"}
    }

    collider.update(dt, solids, collideables, collisionBoxes, positions,
                    velocities)

    assert.are.same(348, positions.mario.y)
    assert.are.same(0, velocities.mario.y)
  end)
end)

describe("with a player overlapping a block from top left", function ()
  it("should push the player to the top", function ()
    local positions = {
      mario = {
        x = 374,
        y = 290
      },
      block = {
        x = 400,
        y = 300
      }
    }
    local velocities = {
      mario = {
        x = 0,
        y = 0
      }
    }
    local collideables = {
      block = {name = "block"}
    }

    collider.update(dt, solids, collideables, collisionBoxes, positions,
                    velocities)

    assert.are.same(374, positions.mario.x)
    assert.are.same(268, positions.mario.y)
  end)
end)

describe("with a player overlapping a block from top right", function ()
  it("should push the player to the top", function ()
    local positions = {
      mario = {
        x = 426,
        y = 290
      },
      block = {
        x = 400,
        y = 300
      }
    }
    local velocities = {
      mario = {
        x = 0,
        y = 0
      }
    }
    local collideables = {
      block = {name = "block"}
    }

    collider.update(dt, solids, collideables, collisionBoxes, positions,
                    velocities)

    assert.are.same(426, positions.mario.x)
    assert.are.same(268, positions.mario.y)
  end)
end)

describe("with a player overlapping a block from bottom left", function ()
  it("should push the player to the bottom", function ()
    local positions = {
      mario = {
        x = 374,
        y = 384
      },
      block = {
        x = 400,
        y = 300
      }
    }
    local velocities = {
      mario = {
        x = 0,
        y = 0
      }
    }
    local collideables = {
      block = {name = "block"}
    }

    collider.update(dt, solids, collideables, collisionBoxes, positions,
                    velocities)

    assert.are.same(374, positions.mario.x)
    assert.are.same(396, positions.mario.y)
  end)
end)

describe("with a player overlapping a block from bottom right", function ()
  it("should push the player to the bottom", function ()
    local positions = {
      mario = {
        x = 426,
        y = 384
      },
      block = {
        x = 400,
        y = 300
      }
    }
    local velocities = {
      mario = {
        x = 0,
        y = 0
      }
    }
    local collideables = {
      block = {name = "block"}
    }

    collider.update(dt, solids, collideables, collisionBoxes, positions,
                    velocities)

    assert.are.same(426, positions.mario.x)
    assert.are.same(396, positions.mario.y)
  end)
end)

describe("with a player touching the left side of a cloud", function ()
  it("should remain the player position and velocity unchanged", function ()
    local positions = {
      mario = {
        x = 280,
        y = 380
      },
      cloud = {
        x = 320,
        y = 348
      }
    }
    local velocities = {
      mario = {
        x = 1400,
        y = 0
      }
    }
    local collideables = {
      cloud = {name = "cloud"}
    }

    collider.update(dt, solids, collideables, collisionBoxes, positions,
                    velocities)

    assert.are.same(280, positions.mario.x)
    assert.are.same(1400, velocities.mario.x)
  end)
end)

describe("with a player touching the right side of a cloud", function ()
  it("should remain the player position and velocity unchanged", function ()
    local positions = {
      mario = {
        x = 366,
        y = 380
      },
      cloud = {
        x = 320,
        y = 348
      }
    }
    local velocities = {
      mario = {
        x = -1400,
        y = 0
      }
    }
    local collideables = {
      cloud = {name = "cloud"}
    }

    collider.update(dt, solids, collideables, collisionBoxes, positions,
                    velocities)

    assert.are.same(366, positions.mario.x)
    assert.are.same(-1400, velocities.mario.x)
  end)
end)

describe("with a player touching the bottom of a cloud", function ()
  it("should remain the player position and velocity unchanged", function ()
    local positions = {
      mario = {
        x = 346,
        y = 486
      },
      cloud = {
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
    local collideables = {
      cloud = {name = "cloud"}
    }

    collider.update(dt, solids, collideables, collisionBoxes, positions,
                    velocities)

    assert.are.same(486, positions.mario.y)
    assert.are.same(-1400, velocities.mario.y)
  end)
end)

describe("with a player touching the top of a cloud", function ()
  it("should stop the player and push it to the top", function ()
    local positions = {
      mario = {
        x = 346,
        y = 370
      },
      cloud = {
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
    local collideables = {
      cloud = {name = "cloud"}
    }

    collider.update(dt, solids, collideables, collisionBoxes, positions,
                    velocities)

    assert.are.same(380, positions.mario.y)
    assert.are.same(0, velocities.mario.y)
  end)
end)

describe("with a player touching the bottom of an upward slope", function ()
  local positions, velocities
  before_each(function ()
    positions = {
      mario = {
        x = 346,
        y = 486
      },
      slope = {
        x = 320,
        y = 380
      }
    }
    velocities = {
      mario = {
        x = 0,
        y = -1400
      }
    }
  end)
  describe("that is rising from left to right", function ()
    it("should push the player to the bottom", function ()
      local collideables = {
        slope = {name = "slope", normalPointingUp = true, rising = true}
      }

      collider.update(dt, solids, collideables, collisionBoxes, positions,
                      velocities)

      assert.are.same(476, positions.mario.y)
    end)
  end)
  describe("that is falling from left to right", function ()
    it("should push the player to the bottom", function ()
      local collideables = {
        slope = {name = "slope", normalPointingUp = true, rising = false}
      }

      collider.update(dt, solids, collideables, collisionBoxes, positions,
                      velocities)

      assert.are.same(476, positions.mario.y)
    end)
  end)
end)

describe("with a player touching the side of an upward slope", function ()
  local positions, velocities
  before_each(function ()
    positions = {
      slope = {
       x = 320,
       y = 380
      }
    }
  end)
  describe("that is rising from left to right", function ()
    it("should stop the player and push it to that side", function ()
      positions.mario = {
        x = 360,
        y = 400
      }
      velocities = {
       mario = {
         x = -1400,
         y = -700
       }
      }
      local collideables = {
       slope = {name = "slope", normalPointingUp = true, rising = true}
      }

      collider.update(dt, solids, collideables, collisionBoxes, positions,
                     velocities)

      assert.are.same(352, positions.mario.x)
      assert.are.same(0, velocities.mario.x)
    end)
  end)
  describe("that is falling from left to right", function ()
    it("should stop the player and push it to that side", function ()
      positions.mario = {
        x = 278,
        y = 400
      }
      velocities = {
       mario = {
         x = 1400,
         y = -700
       }
      }
      local collideables = {
       slope = {name = "slope", normalPointingUp = true, rising = false}
      }

      collider.update(dt, solids, collideables, collisionBoxes, positions,
                     velocities)

      assert.are.same(288, positions.mario.x)
      assert.are.same(0, velocities.mario.x)
    end)
  end)
end)


describe("with a player touching the corner of an upward slope", function ()
  local positions, velocities
  before_each(function ()
    positions = {
      slope = {
       x = 320,
       y = 380
      }
    }
  end)
  describe("that is rising from left to right", function ()
    it("should stop the player and push it away", function ()
      positions.mario = {
        x = 278,
        y = 420
      }
      velocities = {
       mario = {
         x = 1400,
         y = -700
       }
      }
      local collideables = {
       slope = {name = "slope", normalPointingUp = true, rising = true}
      }

      collider.update(dt, solids, collideables, collisionBoxes, positions,
                     velocities)

      assert.are.same(288, positions.mario.x)
      assert.are.same(0, velocities.mario.x)
    end)
  end)
  describe("that is falling from left to right", function ()
    it("should stop the player and push it away", function ()
      positions.mario = {
        x = 360,
        y = 420
      }
      velocities = {
       mario = {
         x = -1400,
         y = -700
       }
      }
      local collideables = {
       slope = {name = "slope", normalPointingUp = true, rising = false}
      }

      collider.update(dt, solids, collideables, collisionBoxes, positions,
                     velocities)

      assert.are.same(352, positions.mario.x)
      assert.are.same(0, velocities.mario.x)
    end)
  end)
end)

describe("with a player falling on an upward slope from above", function ()
  local positions, velocities
  before_each(function ()
    positions = {
      mario = {
       x = 320,
       y = 370
      },
      slope = {
       x = 320,
       y = 380
      }
    }
    velocities = {
     mario = {
       x = 0,
       y = 1400
     }
    }
  end)
  describe("that is rising from left to right", function ()
    it("should put the player exactly on the slope", function ()
      local collideables = {
       slope = {name = "slope", normalPointingUp = true, rising = true}
      }

      collider.update(dt, solids, collideables, collisionBoxes, positions,
                     velocities)

      assert.are.same(380, positions.mario.y)
    end)
  end)
  describe("that is falling from left to right", function ()
    it("should put the player exactly on the slope", function ()
      local collideables = {
       slope = {name = "slope", normalPointingUp = true, rising = false}
      }

      collider.update(dt, solids, collideables, collisionBoxes, positions,
                     velocities)

      assert.are.same(380, positions.mario.y)
    end)
  end)
end)

describe("with a player touching the top of a downward slope", function ()
  local positions, velocities
  before_each(function ()
    positions = {
      mario = {
        x = 346,
        y = 338
      },
      slope = {
        x = 320,
        y = 380
      }
    }
    velocities = {
      mario = {
        x = 0,
        y = 1400
      }
    }
  end)
  describe("that is rising from left to right", function ()
    it("should stop the player and push it to the top", function ()
      local collideables = {
        slope = {name = "slope", normalPointingUp = false, rising = true}
      }

      collider.update(dt, solids, collideables, collisionBoxes, positions,
                      velocities)

      assert.are.same(348, positions.mario.y)
      assert.are.same(0, velocities.mario.y)
    end)
  end)
  describe("that is falling from left to right", function ()
    it("should stop the player and push it to the top", function ()
      local collideables = {
        slope = {name = "slope", normalPointingUp = false, rising = false}
      }

      collider.update(dt, solids, collideables, collisionBoxes, positions,
                      velocities)

      assert.are.same(348, positions.mario.y)
      assert.are.same(0, velocities.mario.y)
    end)
  end)
end)

describe("with a player touching the side of a downward slope", function ()
  local positions, velocities
  before_each(function ()
    positions = {
      slope = {
       x = 320,
       y = 380
      }
    }
  end)
  describe("that is rising from left to right", function ()
    it("should stop the player and push it away", function ()
      positions.mario = {
        x = 278,
        y = 400
      }
      velocities = {
       mario = {
         x = 1400,
         y = -700
       }
      }
      local collideables = {
       slope = {name = "slope", normalPointingUp = false, rising = true}
      }

      collider.update(dt, solids, collideables, collisionBoxes, positions,
                     velocities)

      assert.are.same(288, positions.mario.x)
      assert.are.same(0, velocities.mario.x)
    end)
  end)
  describe("that is falling from left to right", function ()
    it("should stop the player and push it away", function ()
      positions.mario = {
        x = 360,
        y = 400
      }
      velocities = {
       mario = {
         x = -1400,
         y = -700
       }
      }
      local collideables = {
       slope = {name = "slope", normalPointingUp = false, rising = false}
      }

      collider.update(dt, solids, collideables, collisionBoxes, positions,
                     velocities)

      assert.are.same(352, positions.mario.x)
      assert.are.same(0, velocities.mario.x)
    end)
  end)
end)

describe("with a player touching the corner of a downward slope", function ()
  local positions, velocities
  before_each(function ()
    positions = {
      slope = {
       x = 320,
       y = 380
      }
    }
  end)
  describe("that is rising from left to right", function ()
    it("should stop the player and push it to that side", function ()
      positions.mario = {
        x = 360,
        y = 360
      }
      velocities = {
       mario = {
         x = -1400,
         y = -700
       }
      }
      local collideables = {
       slope = {name = "slope", normalPointingUp = false, rising = true}
      }

      collider.update(dt, solids, collideables, collisionBoxes, positions,
                     velocities)

      assert.are.same(352, positions.mario.x)
      assert.are.same(0, velocities.mario.x)
    end)
  end)
  describe("that is falling from left to right", function ()
    it("should stop the player and push it to that side", function ()
      positions.mario = {
        x = 278,
        y = 360
      }
      velocities = {
       mario = {
         x = 1400,
         y = -700
       }
      }
      local collideables = {
       slope = {name = "slope", normalPointingUp = false, rising = false}
      }

      collider.update(dt, solids, collideables, collisionBoxes, positions,
                     velocities)

      assert.are.same(288, positions.mario.x)
      assert.are.same(0, velocities.mario.x)
    end)
  end)
end)

describe("with a player jumping to a downward slope from below", function ()
  local positions, velocities
  before_each(function ()
    positions = {
      mario = {
       x = 320,
       y = 434
      },
      slope = {
       x = 320,
       y = 380
      }
    }
    velocities = {
     mario = {
       x = 0,
       y = -1400
     }
    }
  end)
  describe("that is rising from left to right", function ()
    it("should put the player exactly on the slope", function ()
      local collideables = {
       slope = {name = "slope", normalPointingUp = false, rising = true}
      }

      collider.update(dt, solids, collideables, collisionBoxes, positions,
                     velocities)

      assert.are.same(444, positions.mario.y)
    end)
  end)
  describe("that is falling from left to right", function ()
    it("should put the player exactly on the slope", function ()
      local collideables = {
       slope = {name = "slope", normalPointingUp = false, rising = false}
      }

      collider.update(dt, solids, collideables, collisionBoxes, positions,
                     velocities)

      assert.are.same(444, positions.mario.y)
    end)
  end)
end)
