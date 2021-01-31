local dt = 1 / 70
local collider, components

before_each(function ()
  collider = require "engine.systems.messengers.collision.init"
  components = {
    solid = {
      player = {enabled = true},
    },
    collisionBox = {
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
    },
    gravitational = {},
    climber = {}
  }
end)

after_each(function ()
  package.loaded["engine.systems.messengers.collision.init"] = nil
end)

describe("with a block", function ()
  before_each(function ()
    components.collideable = {
      block = {name = "block"}
    }
  end)

  describe("and a player contacting its left side", function ()
    it("should stop the player and push it to the left", function ()
      components.position = {
        player = {
          x = 280,
          y = 380
        },
        block = {
          x = 320,
          y = 380
        }
      }
      components.velocity = {
        player = {
          x = 1400,
          y = 0
        }
      }

      collider.update(dt, components)

      assert.are.same(288, components.position.player.x)
      assert.are.same(0, components.velocity.player.x)
    end)
  end)

  describe("and a player contacting its right side", function ()
    it("should stop the player and push it to the right", function ()
      components.position = {
        player = {
          x = 366,
          y = 380
        },
        block = {
          x = 320,
          y = 380
        }
      }
      components.velocity = {
        player = {
          x = -1400,
          y = 0
        }
      }

      collider.update(dt, components)

      assert.are.same(352, components.position.player.x)
      assert.are.same(0, components.velocity.player.x)
    end)
  end)

  describe("and a player contacting its bottom", function ()
    it("should stop the player and push it to the bottom", function ()
      components.position = {
        player = {
          x = 346,
          y = 486
        },
        block = {
          x = 320,
          y = 380
        }
      }
      components.velocity = {
        player = {
          x = 0,
          y = -1400
        }
      }

      collider.update(dt, components)

      assert.are.same(476, components.position.player.y)
      assert.are.same(0, components.velocity.player.y)
    end)
  end)

  describe("and a player contacting its top", function ()
    before_each(function ()
      components.position = {
        player = {
          x = 346,
          y = 338
        },
        block = {
          x = 320,
          y = 380
        }
      }
      components.velocity = {
        player = {
          x = 0,
          y = 1400
        }
      }
      components.climber = {
        player = {
          climbing = true,
          trellis = "trellis"
        }
      }
    end)

    it("should stop the player and push it to the top", function ()
      collider.update(dt, components)

      assert.are.same(348, components.position.player.y)
      assert.are.same(0, components.velocity.player.y)
    end)

    it("should not snap the the climber to the trellis", function ()
      collider.update(dt, components)
      
      assert.is.falsy(components.climber.player.climbing)
      assert.is.falsy(components.climber.player.trellis)
    end)
  end)

  describe("and a player overlapping it from top left", function ()
    it("should push the player to the top", function ()
      components.position = {
        player = {
          x = 374,
          y = 290
        },
        block = {
          x = 400,
          y = 300
        }
      }
      components.velocity = {
        player = {
          x = 0,
          y = 0
        }
      }

      collider.update(dt, components)

      assert.are.same(374, components.position.player.x)
      assert.are.same(268, components.position.player.y)
    end)
  end)

  describe("and a player overlapping it from top right", function ()
    before_each(function ()
      components.position = {
        player = {
          x = 426,
          y = 290
        },
        block = {
          x = 400,
          y = 300
        }
      }
      components.velocity = {
        player = {
          x = 0,
          y = 0
        }
      }
      components.climber = {
        player = {
          climbing = true,
          trellis = "trellis"
        }
      }
    end)

    it("should push the player to the top", function ()
      collider.update(dt, components)

      assert.are.same(426, components.position.player.x)
      assert.are.same(268, components.position.player.y)
    end)

    it("should not snap the the climber to the trellis", function ()
      collider.update(dt, components)
      
      assert.is.falsy(components.climber.player.climbing)
      assert.is.falsy(components.climber.player.trellis)
    end)
  end)

  describe("and a player overlapping it from bottom left", function ()
    it("should push the player to the bottom", function ()
      components.position = {
        player = {
          x = 374,
          y = 384
        },
        block = {
          x = 400,
          y = 300
        }
      }
      components.velocity = {
        player = {
          x = 0,
          y = 0
        }
      }

      collider.update(dt, components)

      assert.are.same(374, components.position.player.x)
      assert.are.same(396, components.position.player.y)
    end)
  end)

  describe("and a player overlapping it from bottom right", function ()
    it("should push the player to the bottom", function ()
      components.position = {
        player = {
          x = 426,
          y = 384
        },
        block = {
          x = 400,
          y = 300
        }
      }
      components.velocity = {
        player = {
          x = 0,
          y = 0
        }
      }

      collider.update(dt, components)

      assert.are.same(426, components.position.player.x)
      assert.are.same(396, components.position.player.y)
    end)
  end)
end)

describe("with a cloud", function ()
  before_each(function ()
    components.collideable = {
      cloud = {name = "cloud"}
    }
  end)

  describe("and a player contacting its left side", function ()
    it("should remain the player components.position and velocity unchanged", function ()
      components.position = {
        player = {
          x = 280,
          y = 380
        },
        cloud = {
          x = 320,
          y = 348
        }
      }
      components.velocity = {
        player = {
          x = 1400,
          y = 0
        }
      }

      collider.update(dt, components)

      assert.are.same(280, components.position.player.x)
      assert.are.same(1400, components.velocity.player.x)
    end)
  end)

  describe("and a player contacting its right side", function ()
    it("should remain the player components.position and velocity unchanged", function ()
      components.position = {
        player = {
          x = 366,
          y = 380
        },
        cloud = {
          x = 320,
          y = 348
        }
      }
      components.velocity = {
        player = {
          x = -1400,
          y = 0
        }
      }
      
      collider.update(dt, components)

      assert.are.same(366, components.position.player.x)
      assert.are.same(-1400, components.velocity.player.x)
    end)
  end)

  describe("and a player contacting its bottom", function ()
    it("should remain the player components.position and velocity unchanged", function ()
      components.position = {
        player = {
          x = 346,
          y = 486
        },
        cloud = {
          x = 320,
          y = 380
        }
      }
      components.velocity = {
        player = {
          x = 0,
          y = -1400
        }
      }

      collider.update(dt, components)

      assert.are.same(486, components.position.player.y)
      assert.are.same(-1400, components.velocity.player.y)
    end)
  end)

  describe("and a player contacting its top", function ()
    it("should stop the player and push it to the top", function ()
      components.position = {
        player = {
          x = 346,
          y = 370
        },
        cloud = {
          x = 320,
          y = 380
        }
      }
      components.velocity = {
        player = {
          x = 0,
          y = 1400
        }
      }
      
      collider.update(dt, components)

      assert.are.same(380, components.position.player.y)
      assert.are.same(0, components.velocity.player.y)
    end)
  end)
end)

describe("with a slope", function ()
  before_each(function ()
    components.collideable = {
      slope = {name = "slope"}
    }
    components.position = {
      slope = {
        x = 320,
        y = 380
      }
    }
  end)

  describe("that is rising from left to right", function ()
    before_each(function ()
      components.collideable.slope.rising = true
    end)

    describe("with its normal vector pointing up", function ()
      before_each(function ()
        components.collideable.slope.normalPointingUp = true
      end)

      describe("and a player contacting its bottom", function ()
        it("should push the player to the bottom", function ()
          components.position.player = {
            x = 346,
            y = 486
          }
          components.velocity = {
            player = {
              x = 0,
              y = -1400
            }
          }

          collider.update(dt, components)

          assert.are.same(476, components.position.player.y)
        end)
      end)

      describe("and a player contacting its right side", function ()
        it("should stop the player and push it to the right", function ()
          components.position.player = {
            x = 360,
            y = 400
          }
          components.velocity = {
           player = {
             x = -1400,
             y = -700
           }
          }

          collider.update(dt, components)

          assert.are.same(352, components.position.player.x)
          assert.are.same(0, components.velocity.player.x)
        end)
      end)

      describe("and a player contacting its bottom left corner", function ()
        it("should stop the player and push it to the left", function ()
          components.position.player = {
            x = 278,
            y = 420
          }
          components.velocity = {
            player = {
              x = 1400,
              y = -700
            }
          }

          collider.update(dt, components)
          
          assert.are.same(288, components.position.player.x)
          assert.are.same(0, components.velocity.player.x)
        end)
      end)

      describe("and a player contacting the slope from above", function ()
        it("should put the player exactly on the slope", function ()
          components.position.player = {
            x = 320,
            y = 370
          }
          components.velocity = {
            player = {
              x = 0,
              y = 1400
            }
          }

          collider.update(dt, components)

          assert.are.same(380, components.position.player.y)
        end)
      end)

      describe("and a player overlapping the left side", function ()
        it("should push the player to the left", function()
          components.position.player = {
            x = 300,
            y = 420
          }
          components.velocity = {
            player = {
              x = 0,
              y = 0
            }
          }

          collider.update(dt, components)

          assert.are.same(288, components.position.player.x)
          assert.are.same(420, components.position.player.y)
        end)
      end)

      describe("and a player overlapping the right side", function ()
        it("should push the player to the top", function ()
          components.position.player = {
            x = 344,
            y = 380
          }
          components.velocity = {
            player = {
              x = 0,
              y = 0
            }
          }

          collider.update(dt, components)

          assert.are.same(344, components.position.player.x)
          assert.are.same(348, components.position.player.y)
        end)
      end)

      describe("and a non-gravitational entity going left", function ()
        it("should not change its components.position", function ()
          components.gravitational.player = {enabled = false}
          components.position.player = {
            x = 336,
            y = 348
          }
          components.velocity = {
            player = {
              x = -1400,
              y = 0
            }
          }

          collider.update(dt, components)
          
          assert.are.same(348, components.position.player.y)
        end)
      end)

      describe("and a gravitational entity going left", function ()
        it("should put it exactly on the slope", function ()
          components.gravitational.player = {enabled = true}
          components.position.player = {
            x = 336,
            y = 348
          }
          components.velocity = {
            player = {
              x = -1400,
              y = 0
            }
          }

          collider.update(dt, components)
          
          assert.are.same(388, components.position.player.y)
        end)
      end)
    end)

    describe("with its normal vector pointing down", function ()
      before_each(function ()
        components.collideable.slope.normalPointingUp = false
      end)

      describe("and a player contacting its top", function ()
        it("should push the player to the top", function ()
          components.position.player = {
            x = 346,
            y = 338
          }
          components.velocity = {
            player = {
              x = 0,
              y = 1400
            }
          }
          
          collider.update(dt, components)

          assert.are.same(348, components.position.player.y)
        end)
      end)

      describe("and a player contacting its left side", function ()
        it("should stop the player and push it to the left", function ()
          components.position.player = {
            x = 278,
            y = 400
          }
          components.velocity = {
            player = {
              x = 1400,
              y = -700
            }
          }

          collider.update(dt, components)

          assert.are.same(288, components.position.player.x)
          assert.are.same(0, components.velocity.player.x)
        end)
      end)

      describe("and a player contacting its upper right corner", function ()
        it("should stop the player and push it to the right", function ()
          components.position.player = {
            x = 360,
            y = 360
          }
          components.velocity = {
            player = {
              x = -1400,
              y = -700
            }
          }
          
          collider.update(dt, components)

          assert.are.same(352, components.position.player.x)
          assert.are.same(0, components.velocity.player.x)
        end)
      end)

      describe("and a player contacting the slope from below", function ()
        it("should put the player exactly below the slope", function ()
          components.position.player = {
            x = 320,
            y = 434
          }
          components.velocity = {
            player = {
              x = 0,
              y = -1400
            }
          }
          
          collider.update(dt, components)

          assert.are.same(444, components.position.player.y)
        end)
      end)

      describe("and a player overlapping the right side", function ()
        it("should push the player to the right", function()
          components.position.player = {
            x = 340,
            y = 404
          }
          components.velocity = {
            player = {
              x = 0,
              y = 0
            }
          }
          
          collider.update(dt, components)

          assert.are.same(352, components.position.player.x)
          assert.are.same(404, components.position.player.y)
        end)
      end)

      describe("and a player overlapping the left side", function ()
        it("should push the player to the bottom", function()
          components.position.player = {
            x = 296,
            y = 444
          }
          components.velocity = {
            player = {
              x = 0,
              y = 0
            }
          }
          
          collider.update(dt, components)

          assert.are.same(296, components.position.player.x)
          assert.are.same(476, components.position.player.y)
        end)
      end)
    end)
  end)

  describe("that is falling from left to right", function ()
    before_each(function ()
      components.collideable.slope.rising = false
    end)

    describe("with its normal vector pointing up", function ()
      before_each(function ()
        components.collideable.slope.normalPointingUp = true
      end)

      describe("and a player contacting its bottom", function ()
        it("should push the player to the bottom", function ()
          components.position.player = {
            x = 346,
            y = 486
          }
          components.velocity = {
            player = {
              x = 0,
              y = -1400
            }
          }
          
          collider.update(dt, components)

          assert.are.same(476, components.position.player.y)
        end)
      end)

      describe("and a player contacting its left side", function ()
        it("should stop the player and push it to the left", function ()
          components.position.player = {
            x = 278,
            y = 400
          }
          components.velocity = {
           player = {
             x = 1400,
             y = -700
           }
          }
          
          collider.update(dt, components)

          assert.are.same(288, components.position.player.x)
          assert.are.same(0, components.velocity.player.x)
        end)
      end)

      describe("and a player contacting its bottom right corner", function ()
        it("should stop the player and push it the right", function ()
          components.position.player = {
            x = 360,
            y = 420
          }
          components.velocity = {
            player = {
              x = -1400,
              y = -700
            }
          }
          
          collider.update(dt, components)

          assert.are.same(352, components.position.player.x)
          assert.are.same(0, components.velocity.player.x)
        end)
      end)

      describe("and a player contacting the slope from above", function ()
        it("should put the player exactly on the slope", function ()
          components.position.player = {
            x = 320,
            y = 370
          }
          components.velocity = {
            player = {
              x = 0,
              y = 1400
            }
          }
      
          collider.update(dt, components)

          assert.are.same(380, components.position.player.y)
        end)
      end)
      
      describe("and a player overlapping the right side", function ()
        it("should push the player to the right", function()
          components.position.player = {
            x = 340,
            y = 420
          }
          components.velocity = {
            player = {
              x = 0,
              y = 0
            }
          }
      
          collider.update(dt, components)

          assert.are.same(352, components.position.player.x)
          assert.are.same(420, components.position.player.y)
        end)
      end)
      
      describe("and a player overlapping the left side", function ()
        it("should push the player to the top", function()
          components.position.player = {
            x = 296,
            y = 380
          }
          components.velocity = {
            player = {
              x = 0,
              y = 0
            }
          }
      
          collider.update(dt, components)

          assert.are.same(296, components.position.player.x)
          assert.are.same(348, components.position.player.y)
        end)
      end)

      describe("and a non-gravitational entity going right", function ()
        it("should not change its components.position", function ()
          components.gravitational.player = {enabled = false}
          components.position.player = {
            x = 304,
            y = 348
          }
          components.velocity = {
            player = {
              x = 1400,
              y = 0
            }
          }
      
          collider.update(dt, components)
          assert.are.same(348, components.position.player.y)
        end)
      end)

      describe("and a gravitational entity going right", function ()
        it("should put it exactly on the slope", function ()
          components.gravitational.player = {enabled = true}
          components.position.player = {
            x = 304,
            y = 348
          }
          components.velocity = {
            player = {
              x = 1400,
              y = 0
            }
          }
          
          collider.update(dt, components)
          assert.are.same(388, components.position.player.y)
        end)
      end)
    end)

    describe("with its normal vector pointing down", function ()
      before_each(function ()
        components.collideable.slope.normalPointingUp = false
      end)

      describe("and a player contacting its top", function ()
        it("should push the player to the top", function ()
          components.position.player = {
            x = 346,
            y = 338
          }
          components.velocity = {
            player = {
              x = 0,
              y = 1400
            }
          }
        
          collider.update(dt, components)

          assert.are.same(348, components.position.player.y)
        end)
      end)

      describe("and a player contacting its right side", function ()
        it("should stop the player and push it to the right", function ()
          components.position.player = {
            x = 360,
            y = 400
          }
          components.velocity = {
            player = {
              x = -1400,
              y = -700
            }
          }
          
          collider.update(dt, components)

          assert.are.same(352, components.position.player.x)
          assert.are.same(0, components.velocity.player.x)
        end)
      end)

      describe("and a player contacting its upper left corner", function ()
        it("should stop the player and push it to the left", function ()
          components.position.player = {
            x = 278,
            y = 360
          }
          components.velocity = {
            player = {
              x = 1400,
              y = -700
            }
          }
          
          collider.update(dt, components)
          
          assert.are.same(288, components.position.player.x)
          assert.are.same(0, components.velocity.player.x)
        end)
      end)

      describe("and a player contacting the slope from below", function ()
        it("should put the player exactly below the slope", function ()
          components.position.player = {
            x = 320,
            y = 434
          }
          components.velocity = {
            player = {
              x = 0,
              y = -1400
            }
          }
          
          collider.update(dt, components)

          assert.are.same(444, components.position.player.y)
        end)
      end)

      describe("and a player overlapping the left side", function ()
        it("should push the player to the left", function()
          components.position.player = {
            x = 300,
            y = 404
          }
          components.velocity = {
            player = {
              x = 0,
              y = 0
            }
          }
          
          collider.update(dt, components)

          assert.are.same(288, components.position.player.x)
          assert.are.same(404, components.position.player.y)
        end)
      end)

      describe("and a player overlapping the right side", function ()
        it("should push the player to the bottom", function()
          components.position.player = {
            x = 344,
            y = 444
          }
          components.velocity = {
            player = {
              x = 0,
              y = 0
            }
          }
          
          collider.update(dt, components)

          assert.are.same(344, components.position.player.x)
          assert.are.same(476, components.position.player.y)
        end)
      end)
    end)
  end)
end)

describe("with a block and a slope", function ()
  before_each(function ()
    components.collideable = {
      block = {name = "block"},
      slope = {name = "slope"}
    }
  end)

  describe("to its left", function ()
    before_each(function ()
      components.position = {
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
        components.collideable.slope.normalPointingUp = true
        components.collideable.slope.rising = true
      end)
      
      describe("and a player above it walking to the right", function ()
        it("should let the player walk", function ()
          components.position.player = {
            x = 374,
            y = 320
          }
          components.velocity = {
            player = {
              x = 1400,
              y = 0
            }
          }
          components.solid.player.slope = "slope"
          
          collider.update(dt, components)
          
          assert.are.same(1400, components.velocity.player.x)
          assert.are.same(374, components.position.player.x)
        end)
      end)

      describe("and a player above it overlapping the block", function ()
        it("should not change the components.position of the player", function ()
          components.position.player = {
            x = 394,
            y = 280
          }
          components.velocity = {
            player = {
              x = 0,
              y = 0
            }
          }
          components.solid.player.slope = "slope"
          
          collider.update(dt, components)
          
          assert.are.same(280, components.position.player.y)
        end)
      end)

      describe("and a player going to the block from top left", function ()
        it("should push the player to the top", function ()
          components.position.player = {
            x = 420,
            y = 288
          }
          components.velocity = {
            player = {
              x = 1400,
              y = 700
            }
          }
          components.solid.player.slope = "slope"
          
          collider.update(dt, components)
          
          assert.are.same(268, components.position.player.y)
        end)
      end)
    end)

    describe("whose normal vector is pointing down", function ()
      before_each(function ()
        components.collideable.slope.normalPointingUp = false
        components.collideable.slope.rising = false
      end)
      describe("and a player below it walking to the right", function ()
        it("should let the player walk", function ()
          components.position.player = {
            x = 374,
            y = 364
          }
          components.velocity = {
            player = {
              x = 1400,
              y = 0
            }
          }
          components.solid.player.slope = "slope"
          
          collider.update(dt, components)
          
          assert.are.same(1400, components.velocity.player.x)
          assert.are.same(374, components.position.player.x)
        end)
      end)

      describe("and a player below it overlapping the block", function ()
        it("should not change the components.position of the player", function ()
          components.position.player = {
            x = 394,
            y = 320
          }
          components.velocity = {
            player = {
              x = 0,
              y = 0
            }
          }
          components.solid.player.slope = "slope"
        
          collider.update(dt, components)
          
          assert.are.same(320, components.position.player.y)
        end)
      end)

      describe("and a player going to the block from bottom left", function ()
        it("should push the player to the bottom", function ()
          components.position.player = {
            x = 420,
            y = 386
          }
          components.velocity = {
            player = {
              x = 1400,
              y = -700
            }
          }
          components.solid.player.slope = "slope"
        
          collider.update(dt, components)
        
          assert.are.same(396, components.position.player.y)
        end)
      end)
    end)
  end)

  describe("to its right", function ()
    before_each(function ()
      components.position = {
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
        components.collideable.slope.normalPointingUp = true
        components.collideable.slope.rising = false
      end)
      describe("and a player above it walking to the left", function ()
        it("should let the player walk", function ()
          components.position.player = {
            x = 426,
            y = 320
          }
          components.velocity = {
            player = {
              x = -1400,
              y = 0
            }
          }
          components.solid.player.slope = "slope"
        
          collider.update(dt, components)
        
          assert.are.same(-1400, components.velocity.player.x)
          assert.are.same(426, components.position.player.x)
        end)
      end)

      describe("and a player above it overlapping the block", function ()
        it("should not change the components.position of the player", function ()
          components.position.player = {
            x = 406,
            y = 280
          }
          components.velocity = {
            player = {
              x = 0,
              y = 0
            }
          }
          components.solid.player.slope = "slope"
        
          collider.update(dt, components)
        
          assert.are.same(280, components.position.player.y)
        end)
      end)
      describe("and a player going to the block from top right", function ()
        it("should push the player to the top", function ()
          components.position.player = {
            x = 380,
            y = 288
          }
          components.velocity = {
            player = {
              x = -1400,
              y = 700
            }
          }
          components.solid.player.slope = "slope"
        
          collider.update(dt, components)
        
          assert.are.same(268, components.position.player.y)
        end)
      end)
    end)

    describe("whose normal vector is pointing down", function ()
      before_each(function ()
        components.collideable.slope.normalPointingUp = false
        components.collideable.slope.rising = true
      end)
      describe("and a player below it walking to the left", function ()
        it("should let the player walk", function ()
          components.position.player = {
            x = 426,
            y = 344
          }
          components.velocity = {
            player = {
              x = -1400,
              y = 0
            }
          }
          components.solid.player.slope = "slope"
        
          collider.update(dt, components)
        
          assert.are.same(-1400, components.velocity.player.x)
          assert.are.same(426, components.position.player.x)
        end)
      end)

      describe("and a player below it overlapping the block", function ()
        it("should not change the components.position of the player", function ()
          components.position.player = {
            x = 406,
            y = 384
          }
          components.velocity = {
            player = {
              x = 0,
              y = 0
            }
          }
          components.solid.player.slope = "slope"
        
          collider.update(dt, components)
        
          assert.are.same(384, components.position.player.y)
        end)
      end)

      describe("and a player going to the block from bottom right", function ()
        it("should push the player to the bottom", function ()
          components.position.player = {
            x = 380,
            y = 386
          }
          components.velocity = {
            player = {
              x = -1400,
              y = -700
            }
          }
          components.solid.player.slope = "slope"
      
          collider.update(dt, components)
      
          assert.are.same(396, components.position.player.y)
        end)
      end)
    end)
  end)
end)

describe("with two adjacent slopes", function ()
  before_each(function ()
    components.collideable = {
      slope = {name = "slope"},
      otherSlope = {name = "otherSlope"},
    }
    components.position = {
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
      components.collideable.slope.normalPointingUp = true
      components.collideable.slope.rising = true
      components.collideable.otherSlope.normalPointingUp = true
      components.collideable.otherSlope.rising = false
    end)

    describe("and a player moving to the right on the left slope", function()
      it("should let the player walk", function ()
        components.position.player = {
          x = 374,
          y = 320
        }
        components.velocity = {
          player = {
            x = 1400,
            y = 0
          }
        }
        components.solid.player.slope = "slope"
      
        collider.update(dt, components)
      
        assert.are.same(1400, components.velocity.player.x)
        assert.are.same(374, components.position.player.x)
      end)
    end)

    describe("and a player moving to the left on the right slope", function ()
      it("should let the player walk", function ()
        components.position.player = {
          x = 426,
          y = 320
        }
        components.velocity = {
          player = {
            x = -1400,
            y = 0
          }
        }
        components.solid.player.slope = "otherSlope"
      
        collider.update(dt, components)
      
        assert.are.same(-1400, components.velocity.player.x)
        assert.are.same(426, components.position.player.x)
      end)
    end)
  end)

  describe("facing down", function()
    before_each(function ()
      components.collideable.slope.normalPointingUp = false
      components.collideable.slope.rising = false
      components.collideable.otherSlope.normalPointingUp = false
      components.collideable.otherSlope.rising = true
    end)

    describe("and a player moving to the right under the left slope",
      function ()
        it("should let the player walk", function ()
          components.position.player = {
            x = 374,
            y = 352
          }
          components.velocity = {
            player = {
              x = 1400,
              y = 0
            }
          }
          components.solid.player.slope = "slope"
        
          collider.update(dt, components)
        
          assert.are.same(1400, components.velocity.player.x)
          assert.are.same(374, components.position.player.x)
        end)
      end)

    describe("and a player moving to the left under the right slope",
      function ()
        it("should let the player walk", function ()
          components.position.player = {
            x = 426,
            y = 352
          }
          components.velocity = {
            player = {
              x = -1400,
              y = 0
            }
          }
          components.solid.player.slope = "otherSlope"
        
          collider.update(dt, components)
        
          assert.are.same(-1400, components.velocity.player.x)
          assert.are.same(426, components.position.player.x)
        end)
      end)
  end)
end)

describe("with a block and a disabled solid overlapping it", function ()
  it("should keep the solid in its place", function ()
    components.collideable = {
      block = {name = "block"}
    }
    components.position = {
      player = {
        x = 374,
        y = 290
      },
      block = {
        x = 400,
        y = 300
      }
    }
    components.velocity = {
      player = {
        x = 0,
        y = 0
      }
    }
    components.solid.player.enabled = false

    collider.update(dt, components)

    assert.are.same(374, components.position.player.x)
    assert.are.same(290, components.position.player.y)
  end)
end)