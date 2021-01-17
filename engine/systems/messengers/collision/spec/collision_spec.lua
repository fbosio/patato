local dt = 1 / 70
local collider, solids, collisionBoxes, gravitationals, climbers

before_each(function ()
  collider = require "engine.systems.messengers.collision.init"
  solids = {
    player = {},
  }
  collisionBoxes = {
    player = {
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
    otherSlope = {
      origin = {x = 16, y = 32},
      width = 32,
      height = 64
    }
  }
  gravitationals = {}
  climbers = {}
end)

after_each(function ()
  package.loaded["engine.systems.messengers.collision"] = nil
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
      player = {
        x = 280,
        y = 380
      },
      block = {
        x = 320,
        y = 380
      }
    }
    local velocities = {
      player = {
        x = 1400,
        y = 0
      }
    }

    it("should stop the player and push it to the left", function ()
      collider.update(dt, solids, collideables, collisionBoxes, positions,
                      velocities)

      assert.are.same(288, positions.player.x)
      assert.are.same(0, velocities.player.x)
    end)
  end)

  describe("and a player contacting its right side", function ()
    local positions = {
      player = {
        x = 366,
        y = 380
      },
      block = {
        x = 320,
        y = 380
      }
    }
    local velocities = {
      player = {
        x = -1400,
        y = 0
      }
    }

    it("should stop the player and push it to the right", function ()
      collider.update(dt, solids, collideables, collisionBoxes, positions,
                      velocities)

      assert.are.same(352, positions.player.x)
      assert.are.same(0, velocities.player.x)
    end)
  end)

  describe("and a player contacting its bottom", function ()
    local positions = {
      player = {
        x = 346,
        y = 486
      },
      block = {
        x = 320,
        y = 380
      }
    }
    local velocities = {
      player = {
        x = 0,
        y = -1400
      }
    }

    it("should stop the player and push it to the bottom", function ()
      collider.update(dt, solids, collideables, collisionBoxes, positions,
                      velocities)

      assert.are.same(476, positions.player.y)
      assert.are.same(0, velocities.player.y)
    end)
  end)

  describe("and a player contacting its top", function ()
    local positions, velocities
    
    before_each(function ()
      positions = {
        player = {
          x = 346,
          y = 338
        },
        block = {
          x = 320,
          y = 380
        }
      }
      velocities = {
        player = {
          x = 0,
          y = 1400
        }
      }
      climbers = {
        player = {
          climbing = true,
          trellis = "trellis"
        }
      }
    end)

    it("should stop the player and push it to the top", function ()
      collider.update(dt, solids, collideables, collisionBoxes, positions,
                      velocities)

      assert.are.same(348, positions.player.y)
      assert.are.same(0, velocities.player.y)
    end)

    it("should not snap the the climber to the trellis", function ()
      collider.update(dt, solids, collideables, collisionBoxes, positions,
                      velocities, nil, climbers)
      
      assert.is.falsy(climbers.player.climbing)
      assert.is.falsy(climbers.player.trellis)
    end)
  end)

  describe("and a player overlapping it from top left", function ()
    local positions = {
      player = {
        x = 374,
        y = 290
      },
      block = {
        x = 400,
        y = 300
      }
    }
    local velocities = {
      player = {
        x = 0,
        y = 0
      }
    }

    it("should push the player to the top", function ()
      collider.update(dt, solids, collideables, collisionBoxes, positions,
                      velocities)

      assert.are.same(374, positions.player.x)
      assert.are.same(268, positions.player.y)
    end)
  end)

  describe("and a player overlapping it from top right", function ()
    local positions, velocities
    before_each(function ()
      positions = {
        player = {
          x = 426,
          y = 290
        },
        block = {
          x = 400,
          y = 300
        }
      }
      velocities = {
        player = {
          x = 0,
          y = 0
        }
      }
      climbers = {
        player = {
          climbing = true,
          trellis = "trellis"
        }
      }
    end)

    it("should push the player to the top", function ()
      collider.update(dt, solids, collideables, collisionBoxes, positions,
                      velocities)

      assert.are.same(426, positions.player.x)
      assert.are.same(268, positions.player.y)
    end)

    it("should not snap the the climber to the trellis", function ()
      collider.update(dt, solids, collideables, collisionBoxes, positions,
                      velocities, nil, climbers)
      
      assert.is.falsy(climbers.player.climbing)
      assert.is.falsy(climbers.player.trellis)
    end)
  end)

  describe("and a player overlapping it from bottom left", function ()
    local positions = {
      player = {
        x = 374,
        y = 384
      },
      block = {
        x = 400,
        y = 300
      }
    }
    local velocities = {
      player = {
        x = 0,
        y = 0
      }
    }

    it("should push the player to the bottom", function ()
      collider.update(dt, solids, collideables, collisionBoxes, positions,
                      velocities)

      assert.are.same(374, positions.player.x)
      assert.are.same(396, positions.player.y)
    end)
  end)

  describe("and a player overlapping it from bottom right", function ()
    local positions = {
      player = {
        x = 426,
        y = 384
      },
      block = {
        x = 400,
        y = 300
      }
    }
    local velocities = {
      player = {
        x = 0,
        y = 0
      }
    }

    it("should push the player to the bottom", function ()
      collider.update(dt, solids, collideables, collisionBoxes, positions,
                      velocities)

      assert.are.same(426, positions.player.x)
      assert.are.same(396, positions.player.y)
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
      player = {
        x = 280,
        y = 380
      },
      cloud = {
        x = 320,
        y = 348
      }
    }
    local velocities = {
      player = {
        x = 1400,
        y = 0
      }
    }
    it("should remain the player position and velocity unchanged", function ()
      collider.update(dt, solids, collideables, collisionBoxes, positions,
                      velocities)

      assert.are.same(280, positions.player.x)
      assert.are.same(1400, velocities.player.x)
    end)
  end)

  describe("and a player contacting its right side", function ()
    local positions = {
      player = {
        x = 366,
        y = 380
      },
      cloud = {
        x = 320,
        y = 348
      }
    }
    local velocities = {
      player = {
        x = -1400,
        y = 0
      }
    }
    it("should remain the player position and velocity unchanged", function ()
      collider.update(dt, solids, collideables, collisionBoxes, positions,
                      velocities)

      assert.are.same(366, positions.player.x)
      assert.are.same(-1400, velocities.player.x)
    end)
  end)

  describe("and a player contacting its bottom", function ()
    local positions = {
      player = {
        x = 346,
        y = 486
      },
      cloud = {
        x = 320,
        y = 380
      }
    }
    local velocities = {
      player = {
        x = 0,
        y = -1400
      }
    }
    it("should remain the player position and velocity unchanged", function ()
      collider.update(dt, solids, collideables, collisionBoxes, positions,
                      velocities)

      assert.are.same(486, positions.player.y)
      assert.are.same(-1400, velocities.player.y)
    end)
  end)

  describe("and a player contacting its top", function ()
    local positions = {
      player = {
        x = 346,
        y = 370
      },
      cloud = {
        x = 320,
        y = 380
      }
    }
    local velocities = {
      player = {
        x = 0,
        y = 1400
      }
    }
    it("should stop the player and push it to the top", function ()
      collider.update(dt, solids, collideables, collisionBoxes, positions,
                      velocities)

      assert.are.same(380, positions.player.y)
      assert.are.same(0, velocities.player.y)
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
          positions.player = {
            x = 346,
            y = 486
          }
          velocities = {
            player = {
              x = 0,
              y = -1400
            }
          }
        end)
        it("should push the player to the bottom", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)

          assert.are.same(476, positions.player.y)
        end)
      end)
      describe("and a player contacting its right side", function ()
        before_each(function ()
          positions.player = {
            x = 360,
            y = 400
          }
          velocities = {
           player = {
             x = -1400,
             y = -700
           }
          }
        end)
        it("should stop the player and push it to the right", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                         velocities)

          assert.are.same(352, positions.player.x)
          assert.are.same(0, velocities.player.x)
        end)
      end)
      describe("and a player contacting its bottom left corner", function ()
        before_each(function ()
          positions.player = {
            x = 278,
            y = 420
          }
          velocities = {
            player = {
              x = 1400,
              y = -700
            }
          }
        end)
        it("should stop the player and push it to the left", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                     velocities)

          assert.are.same(288, positions.player.x)
          assert.are.same(0, velocities.player.x)
        end)
      end)
      describe("and a player contacting the slope from above", function ()
        before_each(function ()
          positions.player = {
            x = 320,
            y = 370
          }
          velocities = {
            player = {
              x = 0,
              y = 1400
            }
          }
        end)
        it("should put the player exactly on the slope", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                         velocities)

          assert.are.same(380, positions.player.y)
        end)
      end)
      describe("and a player overlapping the left side", function ()
        before_each(function ()
          positions.player = {
            x = 300,
            y = 420
          }
          velocities = {
            player = {
              x = 0,
              y = 0
            }
          }
        end)
        it("should push the player to the left", function()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)

          assert.are.same(288, positions.player.x)
          assert.are.same(420, positions.player.y)
        end)
      end)
      describe("and a player overlapping the right side", function ()
        before_each(function ()
          positions.player = {
            x = 344,
            y = 380
          }
          velocities = {
            player = {
              x = 0,
              y = 0
            }
          }
        end)
        it("should push the player to the top", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)

          assert.are.same(344, positions.player.x)
          assert.are.same(348, positions.player.y)
        end)
      end)
      describe("and a non-gravitational entity going left", function ()
        before_each(function ()
          gravitationals.player = {enabled = false}
          positions.player = {
            x = 336,
            y = 348
          }
          velocities = {
            player = {
              x = -1400,
              y = 0
            }
          }
        end)
        it("should not change its position", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities, gravitationals)
          assert.are.same(348, positions.player.y)
        end)
      end)
      describe("and a gravitational entity going left", function ()
        before_each(function ()
          gravitationals.player = {enabled = true}
          positions.player = {
            x = 336,
            y = 348
          }
          velocities = {
            player = {
              x = -1400,
              y = 0
            }
          }
        end)
        it("should put it exactly on the slope", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities, gravitationals)
          assert.are.same(388, positions.player.y)
        end)
      end)
    end)

    describe("with its normal vector pointing down", function ()
      before_each(function ()
        collideables.slope.normalPointingUp = false
      end)
      describe("and a player contacting its top", function ()
        before_each(function ()
          positions.player = {
            x = 346,
            y = 338
          }
          velocities = {
            player = {
              x = 0,
              y = 1400
            }
          }
        end)
        it("should push the player to the top", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)

          assert.are.same(348, positions.player.y)
        end)
      end)
      describe("and a player contacting its left side", function ()
        before_each(function ()
          positions.player = {
            x = 278,
            y = 400
          }
          velocities = {
            player = {
              x = 1400,
              y = -700
            }
          }
        end)
        it("should stop the player and push it to the left", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                         velocities)

          assert.are.same(288, positions.player.x)
          assert.are.same(0, velocities.player.x)
        end)
      end)
      describe("and a player contacting its upper right corner", function ()
        before_each(function ()
          positions.player = {
            x = 360,
            y = 360
          }
          velocities = {
            player = {
              x = -1400,
              y = -700
            }
          }
        end)
        it("should stop the player and push it to the right", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                     velocities)

          assert.are.same(352, positions.player.x)
          assert.are.same(0, velocities.player.x)
        end)
      end)
      describe("and a player contacting the slope from below", function ()
        before_each(function ()
          positions.player = {
            x = 320,
            y = 434
          }
          velocities = {
            player = {
              x = 0,
              y = -1400
            }
          }
        end)
        it("should put the player exactly below the slope", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                         velocities)

          assert.are.same(444, positions.player.y)
        end)
      end)
      describe("and a player overlapping the right side", function ()
        before_each(function ()
          positions.player = {
            x = 340,
            y = 404
          }
          velocities = {
            player = {
              x = 0,
              y = 0
            }
          }
        end)
        it("should push the player to the right", function()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)

          assert.are.same(352, positions.player.x)
          assert.are.same(404, positions.player.y)
        end)
      end)
      describe("and a player overlapping the left side", function ()
        before_each(function ()
          positions.player = {
            x = 296,
            y = 444
          }
          velocities = {
            player = {
              x = 0,
              y = 0
            }
          }
        end)
        it("should push the player to the bottom", function()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)

          assert.are.same(296, positions.player.x)
          assert.are.same(476, positions.player.y)
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
          positions.player = {
            x = 346,
            y = 486
          }
          velocities = {
            player = {
              x = 0,
              y = -1400
            }
          }
        end)
        it("should push the player to the bottom", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)

          assert.are.same(476, positions.player.y)
        end)
      end)
      describe("and a player contacting its left side", function ()
        before_each(function ()
          positions.player = {
            x = 278,
            y = 400
          }
          velocities = {
           player = {
             x = 1400,
             y = -700
           }
          }
        end)
        it("should stop the player and push it to the left", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                         velocities)

          assert.are.same(288, positions.player.x)
          assert.are.same(0, velocities.player.x)
        end)
      end)
      describe("and a player contacting its bottom right corner", function ()
        before_each(function ()
          positions.player = {
            x = 360,
            y = 420
          }
          velocities = {
            player = {
              x = -1400,
              y = -700
            }
          }
        end)
        it("should stop the player and push it the right", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)

          assert.are.same(352, positions.player.x)
          assert.are.same(0, velocities.player.x)
        end)
      end)
      describe("and a player contacting the slope from above", function ()
        before_each(function ()
          positions.player = {
            x = 320,
            y = 370
          }
          velocities = {
            player = {
              x = 0,
              y = 1400
            }
          }
        end)
        it("should put the player exactly on the slope", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                         velocities)

          assert.are.same(380, positions.player.y)
        end)
      end)
      describe("and a player overlapping the right side", function ()
        before_each(function ()
          positions.player = {
            x = 340,
            y = 420
          }
          velocities = {
            player = {
              x = 0,
              y = 0
            }
          }
        end)
        it("should push the player to the right", function()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)

          assert.are.same(352, positions.player.x)
          assert.are.same(420, positions.player.y)
        end)
      end)
      describe("and a player overlapping the left side", function ()
        before_each(function ()
          positions.player = {
            x = 296,
            y = 380
          }
          velocities = {
            player = {
              x = 0,
              y = 0
            }
          }
        end)
        it("should push the player to the top", function()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)

          assert.are.same(296, positions.player.x)
          assert.are.same(348, positions.player.y)
        end)
      end)
      describe("and a non-gravitational entity going right", function ()
        before_each(function ()
          gravitationals.player = {enabled = false}
          positions.player = {
            x = 304,
            y = 348
          }
          velocities = {
            player = {
              x = 1400,
              y = 0
            }
          }
        end)
        it("should not change its position", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities, gravitationals)
          assert.are.same(348, positions.player.y)
        end)
      end)
      describe("and a gravitational entity going right", function ()
        before_each(function ()
          gravitationals.player = {enabled = true}
          positions.player = {
            x = 304,
            y = 348
          }
          velocities = {
            player = {
              x = 1400,
              y = 0
            }
          }
        end)
        it("should put it exactly on the slope", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities, gravitationals)
          assert.are.same(388, positions.player.y)
        end)
      end)
    end)

    describe("with its normal vector pointing down", function ()
      before_each(function ()
        collideables.slope.normalPointingUp = false
      end)
      describe("and a player contacting its top", function ()
        before_each(function ()
          positions.player = {
            x = 346,
            y = 338
          }
          velocities = {
            player = {
              x = 0,
              y = 1400
            }
          }
        end)
        it("should push the player to the top", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)

          assert.are.same(348, positions.player.y)
        end)
      end)
      describe("and a player contacting its right side", function ()
        before_each(function ()
          positions.player = {
            x = 360,
            y = 400
          }
          velocities = {
            player = {
              x = -1400,
              y = -700
            }
          }
        end)
        it("should stop the player and push it to the right", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                         velocities)

          assert.are.same(352, positions.player.x)
          assert.are.same(0, velocities.player.x)
        end)
      end)
      describe("and a player contacting its upper left corner", function ()
        before_each(function ()
          positions.player = {
            x = 278,
            y = 360
          }
          velocities = {
            player = {
              x = 1400,
              y = -700
            }
          }
        end)
        it("should stop the player and push it to the left", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                     velocities)

          assert.are.same(288, positions.player.x)
          assert.are.same(0, velocities.player.x)
        end)
      end)
      describe("and a player contacting the slope from below", function ()
        before_each(function ()
          positions.player = {
            x = 320,
            y = 434
          }
          velocities = {
            player = {
              x = 0,
              y = -1400
            }
          }
        end)
        it("should put the player exactly below the slope", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                         velocities)

          assert.are.same(444, positions.player.y)
        end)
      end)
      describe("and a player overlapping the left side", function ()
        before_each(function ()
          positions.player = {
            x = 300,
            y = 404
          }
          velocities = {
            player = {
              x = 0,
              y = 0
            }
          }
        end)
        it("should push the player to the left", function()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)

          assert.are.same(288, positions.player.x)
          assert.are.same(404, positions.player.y)
        end)
      end)
      describe("and a player overlapping the right side", function ()
        before_each(function ()
          positions.player = {
            x = 344,
            y = 444
          }
          velocities = {
            player = {
              x = 0,
              y = 0
            }
          }
        end)
        it("should push the player to the bottom", function()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)

          assert.are.same(344, positions.player.x)
          assert.are.same(476, positions.player.y)
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
          positions.player = {
            x = 374,
            y = 320
          }
          velocities = {
            player = {
              x = 1400,
              y = 0
            }
          }
          solids.player.slope = "slope"
        end)
        it("should let the player walk", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)
          assert.are.same(1400, velocities.player.x)
          assert.are.same(374, positions.player.x)
        end)
      end)

      describe("and a player above it overlapping the block", function ()
        before_each(function ()
          positions.player = {
            x = 394,
            y = 280
          }
          velocities = {
            player = {
              x = 0,
              y = 0
            }
          }
          solids.player.slope = "slope"
        end)
        it("should not change the position of the player", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)
          assert.are.same(280, positions.player.y)
        end)
      end)
      describe("and a player going to the block from top left", function ()
        before_each(function ()
          positions.player = {
            x = 420,
            y = 288
          }
          velocities = {
            player = {
              x = 1400,
              y = 700
            }
          }
          solids.player.slope = "slope"
        end)
        it("should push the player to the top", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)
          assert.are.same(268, positions.player.y)
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
          positions.player = {
            x = 374,
            y = 364
          }
          velocities = {
            player = {
              x = 1400,
              y = 0
            }
          }
          solids.player.slope = "slope"
        end)
        it("should let the player walk", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)
          assert.are.same(1400, velocities.player.x)
          assert.are.same(374, positions.player.x)
        end)
      end)

      describe("and a player below it overlapping the block", function ()
        before_each(function ()
          positions.player = {
            x = 394,
            y = 320
          }
          velocities = {
            player = {
              x = 0,
              y = 0
            }
          }
          solids.player.slope = "slope"
        end)
        it("should not change the position of the player", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)
          assert.are.same(320, positions.player.y)
        end)
      end)
      describe("and a player going to the block from bottom left", function ()
        before_each(function ()
          positions.player = {
            x = 420,
            y = 386
          }
          velocities = {
            player = {
              x = 1400,
              y = -700
            }
          }
          solids.player.slope = "slope"
        end)
        it("should push the player to the bottom", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)
          assert.are.same(396, positions.player.y)
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
          positions.player = {
            x = 426,
            y = 320
          }
          velocities = {
            player = {
              x = -1400,
              y = 0
            }
          }
          solids.player.slope = "slope"
        end)
        it("should let the player walk", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)
          assert.are.same(-1400, velocities.player.x)
          assert.are.same(426, positions.player.x)
        end)
      end)

      describe("and a player above it overlapping the block", function ()
        before_each(function ()
          positions.player = {
            x = 406,
            y = 280
          }
          velocities = {
            player = {
              x = 0,
              y = 0
            }
          }
          solids.player.slope = "slope"
        end)
        it("should not change the position of the player", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)
          assert.are.same(280, positions.player.y)
        end)
      end)
      describe("and a player going to the block from top right", function ()
        before_each(function ()
          positions.player = {
            x = 380,
            y = 288
          }
          velocities = {
            player = {
              x = -1400,
              y = 700
            }
          }
          solids.player.slope = "slope"
        end)
        it("should push the player to the top", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)
          assert.are.same(268, positions.player.y)
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
          positions.player = {
            x = 426,
            y = 344
          }
          velocities = {
            player = {
              x = -1400,
              y = 0
            }
          }
          solids.player.slope = "slope"
        end)
        it("should let the player walk", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)
          assert.are.same(-1400, velocities.player.x)
          assert.are.same(426, positions.player.x)
        end)
      end)

      describe("and a player below it overlapping the block", function ()
        before_each(function ()
          positions.player = {
            x = 406,
            y = 384
          }
          velocities = {
            player = {
              x = 0,
              y = 0
            }
          }
          solids.player.slope = "slope"
        end)
        it("should not change the position of the player", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)
          assert.are.same(384, positions.player.y)
        end)
      end)
      describe("and a player going to the block from bottom right", function ()
        before_each(function ()
          positions.player = {
            x = 380,
            y = 386
          }
          velocities = {
            player = {
              x = -1400,
              y = -700
            }
          }
          solids.player.slope = "slope"
        end)
        it("should push the player to the bottom", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)
          assert.are.same(396, positions.player.y)
        end)
      end)

    end)
  end)

end)

describe("with two adjacent slopes", function ()
  local collideables, positions, velocities
  before_each(function ()
    collideables = {
      slope = {name = "slope"},
      otherSlope = {name = "otherSlope"},
    }
    positions = {
      slope = {
        x = 384,
        y = 300
      },
      otherSlope = {
        x = 416,
        y = 300
      }
    }
  end)
  describe("facing up", function()
    before_each(function ()
      collideables.slope.normalPointingUp = true
      collideables.slope.rising = true
      collideables.otherSlope.normalPointingUp = true
      collideables.otherSlope.rising = false
    end)
    describe("and a player moving to the right on the left slope", function()
      before_each(function ()
        positions.player = {
          x = 374,
          y = 320
        }
        velocities = {
          player = {
            x = 1400,
            y = 0
          }
        }
        solids.player.slope = "slope"
      end)
      it("should let the player walk", function ()
        collider.update(dt, solids, collideables, collisionBoxes, positions,
                        velocities)
        assert.are.same(1400, velocities.player.x)
        assert.are.same(374, positions.player.x)
      end)
    end)
    describe("and a player moving to the left on the right slope", function ()
      before_each(function ()
        positions.player = {
          x = 426,
          y = 320
        }
        velocities = {
          player = {
            x = -1400,
            y = 0
          }
        }
        solids.player.slope = "otherSlope"
      end)
      it("should let the player walk", function ()
        collider.update(dt, solids, collideables, collisionBoxes, positions,
                        velocities)
        assert.are.same(-1400, velocities.player.x)
        assert.are.same(426, positions.player.x)
      end)
    end)
  end)

  describe("facing down", function()
    before_each(function ()
      collideables.slope.normalPointingUp = false
      collideables.slope.rising = false
      collideables.otherSlope.normalPointingUp = false
      collideables.otherSlope.rising = true
    end)
    describe("and a player moving to the right under the left slope",
      function ()
        before_each(function ()
          positions.player = {
            x = 374,
            y = 352
          }
          velocities = {
            player = {
              x = 1400,
              y = 0
            }
          }
          solids.player.slope = "slope"
        end)
        it("should let the player walk", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)
          assert.are.same(1400, velocities.player.x)
          assert.are.same(374, positions.player.x)
        end)
      end)
    describe("and a player moving to the left under the right slope",
      function ()
        before_each(function ()
          positions.player = {
            x = 426,
            y = 352
          }
          velocities = {
            player = {
              x = -1400,
              y = 0
            }
          }
          solids.player.slope = "otherSlope"
        end)
        it("should let the player walk", function ()
          collider.update(dt, solids, collideables, collisionBoxes, positions,
                          velocities)
          assert.are.same(-1400, velocities.player.x)
          assert.are.same(426, positions.player.x)
        end)
      end)
  end)
end)

