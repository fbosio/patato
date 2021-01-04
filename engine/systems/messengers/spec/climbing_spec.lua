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
      climbing.update(climbers, trellises, collisionBoxes, positions,
                      velocities)
      assert.is.falsy(climbers.player.climbing)
    end)
  end)

  describe("and a climber contacting it without climbing", function ()
    it("should not snap the the climber to the trellis", function ()
      positions.player = {x = -32, y = -16}
      local velocities = {
        player = {x = 0, y = 0}
      }
      climbers.player.climbing = false
      climbing.update(climbers, trellises, collisionBoxes, positions,
                      velocities)
      assert.are.same(-32, positions.player.x)
      assert.are.same(-16, positions.player.y)
    end)
  end)

  describe("and a climber climbing", function ()
    before_each(function ()
      climbers.player.climbing = true
    end)
    describe("and overlapping the trellis bottom left", function ()
      it("should match the climber and trellis left sides", function ()
        positions.player = {x = -32, y = 32}
        local velocities = {
          player = {x = 0, y = 0}
        }
        climbing.update(climbers, trellises, collisionBoxes, positions,
                        velocities)
        assert.are.same(-16, positions.player.x)
        assert.are.same(32, positions.player.y)
      end)
    end)
    describe("and overlapping the trellis bottom right", function ()
      it("should match the climber and trellis right sides", function ()
        positions.player = {x = 32, y = 32}
        local velocities = {
          player = {x = 0, y = 0}
        }
        climbing.update(climbers, trellises, collisionBoxes, positions,
                        velocities)
        assert.are.same(16, positions.player.x)
        assert.are.same(32, positions.player.y)
      end)
    end)
    describe("and overlapping the trellis top left", function ()
      it("should match the climber and trellis top left sides", function ()
        positions.player = {x = -32, y = -96}
        local velocities = {
          player = {x = 0, y = 0}
        }
        climbing.update(climbers, trellises, collisionBoxes, positions,
                        velocities)
        assert.are.same(-16, positions.player.x)
        assert.are.same(-64, positions.player.y)
      end)
    end)
    describe("and overlapping the trellis top right", function ()
      it("should match the climber and trellis top right sides", function ()
        positions.player = {x = 32, y = -96}
        local velocities = {
          player = {x = 0, y = 0}
        }
        climbing.update(climbers, trellises, collisionBoxes, positions,
                        velocities)
        assert.are.same(16, positions.player.x)
        assert.are.same(-64, positions.player.y)
      end)
    end)
  end)
end)
