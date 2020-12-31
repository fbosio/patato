local dt = 1 / 70
local collider, solids, collisionBoxes

before_each(function ()
  collider = require "engine.systems.collider"
  solids = {
    mario = {},
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
  solids.mario.slope = nil
end)

describe("with a block", function ()
  local collideables
  before_each(function ()
    collideables = {
      block = {name = "block"}
    }
  end)

  describe("and a player contacting its left side", function ()
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

    it("should stop the player and push it to the left", function ()
      collider.update(dt, solids, collideables, collisionBoxes, positions,
                      velocities)

      assert.are.same(288, positions.mario.x)
      assert.are.same(0, velocities.mario.x)
    end)
  end)

  describe("and a player contacting its right side", function ()
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

    it("should stop the player and push it to the right", function ()
      collider.update(dt, solids, collideables, collisionBoxes, positions,
                      velocities)

      assert.are.same(352, positions.mario.x)
      assert.are.same(0, velocities.mario.x)
    end)
  end)

  describe("and a player contacting its bottom", function ()
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

    it("should stop the player and push it to the bottom", function ()
      collider.update(dt, solids, collideables, collisionBoxes, positions,
                      velocities)

    assert.are.same(476, positions.mario.y)
    assert.are.same(0, velocities.mario.y)
    end)
  end)

  describe("and a player contacting its top", function ()
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

    it("should stop the player and push it to the top", function ()
      collider.update(dt, solids, collideables, collisionBoxes, positions,
                      velocities)

    assert.are.same(348, positions.mario.y)
    assert.are.same(0, velocities.mario.y)
    end)
  end)

  describe("and a player overlapping it from top left", function ()
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

    it("should push the player to the top", function ()
      collider.update(dt, solids, collideables, collisionBoxes, positions,
                      velocities)

      assert.are.same(374, positions.mario.x)
      assert.are.same(268, positions.mario.y)
    end)
  end)

  describe("and a player overlapping it from top right", function ()
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

    it("should push the player to the top", function ()
      collider.update(dt, solids, collideables, collisionBoxes, positions,
                      velocities)

    assert.are.same(426, positions.mario.x)
    assert.are.same(268, positions.mario.y)
    end)
  end)

  describe("and a player overlapping it from bottom left", function ()
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

    it("should push the player to the bottom", function ()
      collider.update(dt, solids, collideables, collisionBoxes, positions,
                      velocities)

      assert.are.same(374, positions.mario.x)
      assert.are.same(396, positions.mario.y)
    end)
  end)

  describe("and a player overlapping it from bottom right", function ()
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

    it("should push the player to the bottom", function ()
      collider.update(dt, solids, collideables, collisionBoxes, positions,
                      velocities)

      assert.are.same(426, positions.mario.x)
      assert.are.same(396, positions.mario.y)
    end)
  end)
end)

describe("with a cloud", function ()
  local collideables
  before_each(function ()
    collideables = {
      cloud = {name = "cloud"}
    }
  end)

  describe("and a player contacting its left side", function ()
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
    it("should remain the player position and velocity unchanged", function ()
      collider.update(dt, solids, collideables, collisionBoxes, positions,
                      velocities)

      assert.are.same(280, positions.mario.x)
      assert.are.same(1400, velocities.mario.x)
    end)
  end)

  describe("and a player contacting its right side", function ()
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
    it("should remain the player position and velocity unchanged", function ()
      collider.update(dt, solids, collideables, collisionBoxes, positions,
                      velocities)

      assert.are.same(366, positions.mario.x)
      assert.are.same(-1400, velocities.mario.x)
    end)
  end)

  describe("and a player contacting its bottom", function ()
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
    it("should remain the player position and velocity unchanged", function ()
      collider.update(dt, solids, collideables, collisionBoxes, positions,
                      velocities)

      assert.are.same(486, positions.mario.y)
      assert.are.same(-1400, velocities.mario.y)
    end)
  end)

  describe("and a player contacting its top", function ()
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
    it("should stop the player and push it to the top", function ()
      collider.update(dt, solids, collideables, collisionBoxes, positions,
                      velocities)

      assert.are.same(380, positions.mario.y)
      assert.are.same(0, velocities.mario.y)
    end)
  end)
end)

describe("with a slope", function ()
  local collideables, positions, velocities
  before_each(function ()
    collideables = {
      slope = {name = "slope"}
    }
    positions = {
      slope = {
        x = 320,
        y = 380
      }
    }
  end)

  describe("that is rising from left to right", function ()
    before_each(function ()
      collideables.slope.rising = true
    end)

    describe("with its normal vector pointing up", function ()
      before_each(function ()
        collideables.slope.normalPointingUp = true
      end)
      describe("and a player contacting its bottom", function ()
        before_each(function ()
          positions.mario = {
            x = 346,
            y = 486
          }
          velocities = {
            mario = {
              x = 0,
              y = -1400
            }
          }
        end)
        it("should push the player to the bottom", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)

          assert.are.same(476, positions.mario.y)
        end)
      end)
      describe("and a player contacting its right side", function ()
        before_each(function ()
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
        end)
        it("should stop the player and push it to the right", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                         velocities)

          assert.are.same(352, positions.mario.x)
          assert.are.same(0, velocities.mario.x)
        end)
      end)
      describe("and a player contacting its bottom left corner", function ()
        before_each(function ()
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
        end)
        it("should stop the player and push it to the left", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                     velocities)

          assert.are.same(288, positions.mario.x)
          assert.are.same(0, velocities.mario.x)
        end)
      end)
      describe("and a player contacting the slope from above", function ()
        before_each(function ()
          positions.mario = {
            x = 320,
            y = 370
          }
          velocities = {
            mario = {
              x = 0,
              y = 1400
            }
          }
        end)
        it("should put the player exactly on the slope", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                         velocities)

          assert.are.same(380, positions.mario.y)
        end)
      end)
    end)

    describe("with its normal vector pointing down", function ()
      before_each(function ()
        collideables.slope.normalPointingUp = false
      end)
      describe("and a player contacting its top", function ()
        before_each(function ()
          positions.mario = {
            x = 346,
            y = 338
          }
          velocities = {
            mario = {
              x = 0,
              y = 1400
            }
          }
        end)
        it("should push the player to the top", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)

          assert.are.same(348, positions.mario.y)
        end)
      end)
      describe("and a player contacting its left side", function ()
        before_each(function ()
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
        end)
        it("should stop the player and push it to the left", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                         velocities)

          assert.are.same(288, positions.mario.x)
          assert.are.same(0, velocities.mario.x)
        end)
      end)
      describe("and a player contacting its upper right corner", function ()
        before_each(function ()
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
        end)
        it("should stop the player and push it to the right", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                     velocities)

          assert.are.same(352, positions.mario.x)
          assert.are.same(0, velocities.mario.x)
        end)
      end)
      describe("and a player contacting the slope from below", function ()
        before_each(function ()
          positions.mario = {
            x = 320,
            y = 434
          }
          velocities = {
            mario = {
              x = 0,
              y = -1400
            }
          }
        end)
        it("should put the player exactly below the slope", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                         velocities)

          assert.are.same(444, positions.mario.y)
        end)
      end)
    end)
  end)

  describe("that is falling from left to right", function ()
    before_each(function ()
      collideables.slope.rising = false
    end)

    describe("with its normal vector pointing up", function ()
      before_each(function ()
        collideables.slope.normalPointingUp = true
      end)
      describe("and a player contacting its bottom", function ()
        before_each(function ()
          positions.mario = {
            x = 346,
            y = 486
          }
          velocities = {
            mario = {
              x = 0,
              y = -1400
            }
          }
        end)
        it("should push the player to the bottom", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)

          assert.are.same(476, positions.mario.y)
        end)
      end)
      describe("and a player contacting its left side", function ()
        before_each(function ()
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
        end)
        it("should stop the player and push it to the left", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                         velocities)

          assert.are.same(288, positions.mario.x)
          assert.are.same(0, velocities.mario.x)
        end)
      end)
      describe("and a player contacting its bottom right corner", function ()
        before_each(function ()
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
        end)
        it("should stop the player and push it the right", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)

          assert.are.same(352, positions.mario.x)
          assert.are.same(0, velocities.mario.x)
        end)
      end)
      describe("and a player contacting the slope from above", function ()
        before_each(function ()
          positions.mario = {
            x = 320,
            y = 370
          }
          velocities = {
            mario = {
              x = 0,
              y = 1400
            }
          }
        end)
        it("should put the player exactly on the slope", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                         velocities)

          assert.are.same(380, positions.mario.y)
        end)
      end)
    end)

    describe("with its normal vector pointing down", function ()
      before_each(function ()
        collideables.slope.normalPointingUp = false
      end)
      describe("and a player contacting its top", function ()
        before_each(function ()
          positions.mario = {
            x = 346,
            y = 338
          }
          velocities = {
            mario = {
              x = 0,
              y = 1400
            }
          }
        end)
        it("should push the player to the top", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)

          assert.are.same(348, positions.mario.y)
        end)
      end)
      describe("and a player contacting its right side", function ()
        before_each(function ()
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
        end)
        it("should stop the player and push it to the right", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                         velocities)

          assert.are.same(352, positions.mario.x)
          assert.are.same(0, velocities.mario.x)
        end)
      end)
      describe("and a player contacting its upper left corner", function ()
        before_each(function ()
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
        end)
        it("should stop the player and push it to the left", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                     velocities)

          assert.are.same(288, positions.mario.x)
          assert.are.same(0, velocities.mario.x)
        end)
      end)
      describe("and a player contacting the slope from below", function ()
        before_each(function ()
          positions.mario = {
            x = 320,
            y = 434
          }
          velocities = {
            mario = {
              x = 0,
              y = -1400
            }
          }
        end)
        it("should put the player exactly below the slope", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                         velocities)

          assert.are.same(444, positions.mario.y)
        end)
      end)
    end)
  end)
end)

describe("with a block and a slope", function ()
  local collideables, positions, velocities
  before_each(function ()
    collideables = {
      block = {name = "block"},
      slope = {name = "slope"}
    }
  end)

  describe("to its left", function ()
    before_each(function ()
      positions = {
        block = {
          x = 416,
          y = 300
        },
        slope = {
          x = 384,
          y = 300
        }
      }
    end)
    describe("whose normal vector is pointing up", function ()
      before_each(function ()
        collideables.slope.normalPointingUp = true
        collideables.slope.rising = true
      end)
      describe("and a player above it walking to the right", function ()
        before_each(function ()
          positions.mario = {
            x = 374,
            y = 320
          }
          velocities = {
            mario = {
              x = 1400,
              y = 0
            }
          }
          solids.mario.slope = "slope"
        end)
        it("should let the player walk", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)
          assert.are.same(1400, velocities.mario.x)
          assert.are.same(374, positions.mario.x)
        end)
      end)

      describe("and a player above it overlapping the block", function ()
        before_each(function ()
          positions.mario = {
            x = 394,
            y = 280
          }
          velocities = {
            mario = {
              x = 0,
              y = 0
            }
          }
          solids.mario.slope = "slope"
        end)
        it("should not change the position of the player", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)
          assert.are.same(280, positions.mario.y)
        end)
      end)
    end)

    describe("whose normal vector is pointing down", function ()
      before_each(function ()
        collideables.slope.normalPointingUp = false
        collideables.slope.rising = false
      end)
      describe("and a player below it walking to the right", function ()
        before_each(function ()
          positions.mario = {
            x = 374,
            y = 364
          }
          velocities = {
            mario = {
              x = 1400,
              y = 0
            }
          }
          solids.mario.slope = "slope"
        end)
        it("should let the player walk", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)
          assert.are.same(1400, velocities.mario.x)
          assert.are.same(374, positions.mario.x)
        end)
      end)

      describe("and a player below it overlapping the block", function ()
        before_each(function ()
          positions.mario = {
            x = 394,
            y = 320
          }
          velocities = {
            mario = {
              x = 0,
              y = 0
            }
          }
          solids.mario.slope = "slope"
        end)
        it("should not change the position of the player", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)
          assert.are.same(320, positions.mario.y)
        end)
      end)
    end)
  end)

  describe("to its right", function ()
    before_each(function ()
      positions = {
        block = {
          x = 384,
          y = 300
        },
        slope = {
          x = 416,
          y = 300
        }
      }
    end)
    describe("whose normal vector is pointing up", function ()
      before_each(function ()
        collideables.slope.normalPointingUp = true
        collideables.slope.rising = false
      end)
      describe("and a player above it walking to the left", function ()
        before_each(function ()
          positions.mario = {
            x = 426,
            y = 320
          }
          velocities = {
            mario = {
              x = -1400,
              y = 0
            }
          }
          solids.mario.slope = "slope"
        end)
        it("should let the player walk", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)
          assert.are.same(-1400, velocities.mario.x)
          assert.are.same(426, positions.mario.x)
        end)
      end)

      describe("and a player above it overlapping the block", function ()
        before_each(function ()
          positions.mario = {
            x = 406,
            y = 280
          }
          velocities = {
            mario = {
              x = 0,
              y = 0
            }
          }
          solids.mario.slope = "slope"
        end)
        it("should not change the position of the player", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)
          assert.are.same(280, positions.mario.y)
        end)
      end)
    end)

    describe("whose normal vector is pointing down", function ()
      before_each(function ()
        collideables.slope.normalPointingUp = false
        collideables.slope.rising = true
      end)
      describe("and a player below it walking to the left", function ()
        before_each(function ()
          positions.mario = {
            x = 426,
            y = 344
          }
          velocities = {
            mario = {
              x = -1400,
              y = 0
            }
          }
          solids.mario.slope = "slope"
        end)
        it("should let the player walk", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)
          assert.are.same(-1400, velocities.mario.x)
          assert.are.same(426, positions.mario.x)
        end)
      end)

      describe("and a player below it overlapping the block", function ()
        before_each(function ()
          positions.mario = {
            x = 406,
            y = 384
          }
          velocities = {
            mario = {
              x = 0,
              y = 0
            }
          }
          solids.mario.slope = "slope"
        end)
        it("should not change the position of the player", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)
          assert.are.same(384, positions.mario.y)
        end)
      end)
    end)
  end)
end)
