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
  local trellises
  before_each(function ()
    trellises = {
      trellis = {name = "trellis"}
    }
  end)

  describe("and a climber not contacting it", function ()
    it("should not consider the climber", function ()
      local positions = {
        player = {x = -96, y = 0},
        trellis = {x = 0, y = 0}
      }
      local velocities = {
        player = {x = 0, y = 0}
      }
      climbers.player.climbing = true
      climbing.update(climbers, trellises, collisionBoxes, positions,
                      velocities)
      assert.is.falsy(climbers.player.climbing)
    end)
  end)

  describe("and a climber contacting it", function ()
    local positions, velocities
    before_each(function ()
      positions = {
        player = {x = -32, y = -32},
        trellis = {x = 0, y = 0}
      }
      velocities = {
        player = {x = 0, y = 0}
      }
    end)
    describe("and not climbing", function ()
      it("should not snap the the climber to the trellis", function ()
        climbers.player.climbing = false
        climbing.update(climbers, trellises, collisionBoxes, positions,
                        velocities)
        assert.are.same(-32, positions.player.x)
      end)
    end)
    describe("and climbing", function ()
      it("should snap the the climber to the trellis", function ()
        climbers.player.climbing = true
        climbing.update(climbers, trellises, collisionBoxes, positions,
                        velocities)
        assert.are.same(-16, positions.player.x)
      end)
    end)
  end)

end)
