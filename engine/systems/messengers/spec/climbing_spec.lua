local dt = 1 / 70
local climbing, components

before_each(function ()
  climbing = require "engine.systems.messengers.climbing"
  components = {
    climber = {
      player = {enabled = true}
    },
    collisionBox = {
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
    },
    velocity = {
      player = {x = 0, y = 0}
    }
  }
end)

after_each(function ()
  package.loaded["engine.systems.messengers.climbing"] = nil
end)

describe("with a trellis", function ()
  before_each(function ()
    components.trellis = {
      trellis = {name = "trellis"}
    }
    components.position = {
      trellis = {x = 0, y = 0}
    }
  end)

  describe("and a climber not contacting it", function ()
    it("should not consider the climber", function ()
      components.position.player = {x = -96, y = 0}
      components.climber.player.climbing = true
      components.climber.player.trellis = "trellis"
      climbing.update(dt, components)
      assert.is.falsy(components.climber.player.climbing)
      assert.is.falsy(components.climber.player.trellis)
    end)
  end)

  describe("and a climber contacting it without climbing", function ()
    it("should not snap the the climber to the trellis", function ()
      components.position.player = {x = -32, y = -16}
      components.climber.player.climbing = false
      climbing.update(dt, components)
      assert.are.same(-32, components.position.player.x)
      assert.are.same(-16, components.position.player.y)
      assert.is.falsy(components.climber.player.trellis)
    end)
  end)

  describe("and a climber climbing", function ()
    before_each(function ()
      components.climber.player.climbing = true
      components.climber.player.trellis = "trellis"
    end)

    describe("and overlapping the trellis bottom left", function ()
      before_each(function ()
        components.position.player = {x = -32, y = 32}
      end)
      it("should match the climber and trellis left sides", function ()
        climbing.update(dt, components)
        assert.are.same(-16, components.position.player.x)
        assert.are.same(32, components.position.player.y)
        assert.are.same("trellis", components.climber.player.trellis)
      end)
      it("should prevent the player from moving left", function ()
        components.velocity = {
          player = {x = -700, y = 700}
        }
        climbing.update(dt, components)
        assert.are.same(0, components.velocity.player.x)
        assert.are.same(700, components.velocity.player.y)
      end)
    end)

    describe("and overlapping the trellis bottom right", function ()
      before_each(function ()
        components.position.player = {x = 32, y = 32}
      end)
      it("should match the climber and trellis right sides", function ()
        components.velocity = {
          player = {x = 0, y = 0}
        }
        climbing.update(dt, components)
        assert.are.same(16, components.position.player.x)
        assert.are.same(32, components.position.player.y)
        assert.are.same("trellis", components.climber.player.trellis)
      end)
      it("should prevent the player from moving right", function ()
        components.velocity = {
          player = {x = 700, y = 700}
        }
        climbing.update(dt, components)
        assert.are.same(0, components.velocity.player.x)
        assert.are.same(700, components.velocity.player.y)
      end)
    end)

    describe("and overlapping the trellis top left", function ()
      before_each(function ()
        components.position.player = {x = -32, y = -96}
      end)
      it("should match the climber and trellis top left sides", function ()
        components.velocity = {
          player = {x = 0, y = 0}
        }
        climbing.update(dt, components)
        assert.are.same(-16, components.position.player.x)
        assert.are.same(-64, components.position.player.y)
        assert.are.same("trellis", components.climber.player.trellis)
      end)
      it("should prevent the player from moving up left", function ()
        components.velocity = {
          player = {x = -700, y = -700}
        }
        climbing.update(dt, components)
        assert.are.same(0, components.velocity.player.x)
        assert.are.same(0, components.velocity.player.y)
      end)
    end)

    describe("and overlapping the trellis top right", function ()
      before_each(function ()
        components.position.player = {x = 32, y = -96}
      end)
      it("should match the climber and trellis top right sides", function ()
        components.velocity = {
          player = {x = 0, y = 0}
        }
        climbing.update(dt, components)
        assert.are.same(16, components.position.player.x)
        assert.are.same(-64, components.position.player.y)
        assert.are.same("trellis", components.climber.player.trellis)
      end)
      it("should prevent the player from moving up right", function ()
        components.velocity = {
          player = {x = 700, y = -700}
        }
        climbing.update(dt, components)
        assert.are.same(0, components.velocity.player.x)
        assert.are.same(0, components.velocity.player.y)
      end)
    end)
  end)

  describe("and a gravitational climber climbing", function ()
    it("should disable the gravitational component", function ()
      components.gravitational = {
        player = {enabled = true}
      }
      components.position.player = {x = 0, y = -16}
      components.climber.player.climbing = true
      climbing.update(dt, components)
      
      assert.is.falsy(components.gravitational.player.enabled)
    end)
  end)

  describe("and a gravitational climber not climbing", function ()
    it("should enable the gravitational component", function ()
      components.gravitational = {
        player = {enabled = false}
      }
      components.position.player = {x = 96, y = 0}
      components.climber.player.climbing = false
      climbing.update(dt, components)
      
      assert.is.truthy(components.gravitational.player.enabled)
    end)
  end)

  describe("and a gravitational entity jumping off the trellis", function ()
    it("should unset trellis reference of the climber", function ()
      components.gravitational = {
        player = {enabled = false}
      }
      components.position.player = {x = 0, y = 0}
      components.climber.player.climbing = false
      components.climber.player.trellis = "trellis"
      climbing.update(dt, components)
      
      assert.is.falsy(components.climber.player.trellis)
    end)
  end)

  describe("and a disabled climber trying to climb", function ()
    it("should not consider the climber", function ()
      components.position.player = {x = 32, y = -96}
      components.climber.player.enabled = false
      components.climber.player.climbing = true
      components.climber.player.trellis = "trellis"

      climbing.update(dt, components)
      
      assert.is.falsy(components.climber.player.climbing)
      assert.is.falsy(components.climber.player.trellis)
    end)
  end)
end)
