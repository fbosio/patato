local dt = 1 / 70
local climbing, climbers, collisionBoxes

before_each(function ()
  climbing = require "engine.systems.messengers.climbing"
  climbers = {
    player = {}
  }
  collisionBoxes = {
    player = {
      origin = {x = 16, y = 64},
      width = 32,
      height = 64
    },
    trellis = {
      origin = {x = 32, y = 128},
      width = 64,
      height = 128
    }
  }
end)

after_each(function ()
  package.loaded["engine.systems.messengers.climbing"] = nil
end)

describe("with a trellis", function ()
  local trellises, positions
  before_each(function ()
    trellises = {
      trellis = {name = "trellis"}
    }
    positions = {
      trellis = {x = 0, y = 0}
    }
  end)

  describe("and a climber not contacting it", function ()
    it("should not consider the climber", function ()
      positions.player = {x = -96, y = 0}
      local velocities = {
        player = {x = 0, y = 0}
      }
      climbers.player.climbing = true
      climbers.player.trellis = "trellis"
      climbing.update(dt, climbers, trellises, collisionBoxes, positions,
                      velocities)
      assert.is.falsy(climbers.player.climbing)
      assert.is.falsy(climbers.player.trellis)
    end)
  end)

  describe("and a climber contacting it without climbing", function ()
    it("should not snap the the climber to the trellis", function ()
      positions.player = {x = -32, y = -16}
      local velocities = {
        player = {x = 0, y = 0}
      }
      climbers.player.climbing = false
      climbing.update(dt, climbers, trellises, collisionBoxes, positions,
                      velocities)
      assert.are.same(-32, positions.player.x)
      assert.are.same(-16, positions.player.y)
      assert.is.falsy(climbers.player.trellis)
    end)
  end)

  describe("and a climber climbing", function ()
    before_each(function ()
      climbers.player.climbing = true
      climbers.player.trellis = "trellis"
    end)

    describe("and overlapping the trellis bottom left", function ()
      local velocities
      before_each(function ()
        positions.player = {x = -32, y = 32}
      end)
      it("should match the climber and trellis left sides", function ()
        velocities = {
          player = {x = 0, y = 0}
        }
        climbing.update(dt, climbers, trellises, collisionBoxes, positions,
                        velocities)
        assert.are.same(-16, positions.player.x)
        assert.are.same(32, positions.player.y)
        assert.are.same("trellis", climbers.player.trellis)
      end)
      it("should prevent the player from moving left", function ()
        velocities = {
          player = {x = -700, y = 700}
        }
        climbing.update(dt, climbers, trellises, collisionBoxes, positions,
                        velocities)
        assert.are.same(0, velocities.player.x)
        assert.are.same(700, velocities.player.y)
      end)
    end)

    describe("and overlapping the trellis bottom right", function ()
      local velocities
      before_each(function ()
        positions.player = {x = 32, y = 32}
      end)
      it("should match the climber and trellis right sides", function ()
        velocities = {
          player = {x = 0, y = 0}
        }
        climbing.update(dt, climbers, trellises, collisionBoxes, positions,
                        velocities)
        assert.are.same(16, positions.player.x)
        assert.are.same(32, positions.player.y)
        assert.are.same("trellis", climbers.player.trellis)
      end)
      it("should prevent the player from moving right", function ()
        velocities = {
          player = {x = 700, y = 700}
        }
        climbing.update(dt, climbers, trellises, collisionBoxes, positions,
                        velocities)
        assert.are.same(0, velocities.player.x)
        assert.are.same(700, velocities.player.y)
      end)
    end)

    describe("and overlapping the trellis top left", function ()
      local velocities
      before_each(function ()
        positions.player = {x = -32, y = -96}
      end)
      it("should match the climber and trellis top left sides", function ()
        velocities = {
          player = {x = 0, y = 0}
        }
        climbing.update(dt, climbers, trellises, collisionBoxes, positions,
                        velocities)
        assert.are.same(-16, positions.player.x)
        assert.are.same(-64, positions.player.y)
        assert.are.same("trellis", climbers.player.trellis)
      end)
      it("should prevent the player from moving up left", function ()
        velocities = {
          player = {x = -700, y = -700}
        }
        climbing.update(dt, climbers, trellises, collisionBoxes, positions,
                        velocities)
        assert.are.same(0, velocities.player.x)
        assert.are.same(0, velocities.player.y)
      end)
    end)

    describe("and overlapping the trellis top right", function ()
      local velocities
      before_each(function ()
        positions.player = {x = 32, y = -96}
      end)
      it("should match the climber and trellis top right sides", function ()
        velocities = {
          player = {x = 0, y = 0}
        }
        climbing.update(dt, climbers, trellises, collisionBoxes, positions,
                        velocities)
        assert.are.same(16, positions.player.x)
        assert.are.same(-64, positions.player.y)
        assert.are.same("trellis", climbers.player.trellis)
      end)
      it("should prevent the player from moving up right", function ()
        velocities = {
          player = {x = 700, y = -700}
        }
        climbing.update(dt, climbers, trellises, collisionBoxes, positions,
                        velocities)
        assert.are.same(0, velocities.player.x)
        assert.are.same(0, velocities.player.y)
      end)
    end)
  end)

  describe("and a gravitational climber climbing", function ()
    it("should disable the gravitational component", function ()
      local gravitationals = {
        player = {enabled = true}
      }
      positions.player = {x = 0, y = -16}
      climbers.player.climbing = true
      local velocities = {
        player = {x = 0, y = 0}
      }
      climbing.update(dt, climbers, trellises, collisionBoxes, positions,
                      velocities, gravitationals)
      
      assert.is.falsy(gravitationals.player.enabled)
    end)
  end)

  describe("and a gravitational climber not climbing", function ()
    it("should enable the gravitational component", function ()
      local gravitationals = {
        player = {enabled = false}
      }
      positions.player = {x = 96, y = 0}
      climbers.player.climbing = false
      local velocities = {
        player = {x = 0, y = 0}
      }
      climbing.update(dt, climbers, trellises, collisionBoxes, positions,
                      velocities, gravitationals)
      
      assert.is.truthy(gravitationals.player.enabled)
    end)
  end)

  describe("and a gravitational entity jumping off the trellis", function ()
    it("should unset trellis reference of the climber", function ()
      local gravitationals = {
        player = {enabled = false}
      }
      positions.player = {x = 0, y = 0}
      climbers.player.climbing = false
      climbers.player.trellis = "trellis"
      local velocities = {
        player = {x = 0, y = -100}
      }
      climbing.update(dt, climbers, trellises, collisionBoxes, positions,
                      velocities, gravitationals)
      
      assert.is.falsy(climbers.player.trellis)
    end)
  end)
end)
