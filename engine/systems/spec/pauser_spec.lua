local pauser

before_each(function ()
  pauser = require "engine.systems.pauser"
end)

after_each(function ()
  package.loaded["engine.systems.pauser"] = nil
end)

describe("with some enabled components", function ()
  local components
  before_each(function ()
    components = {
      animation = {
        player = {enabled = true}
      },
      gravitational = {
        player = {enabled = false}
      },
      velocity = {
        player = {enabled = true}
      }
    }
  end)
  
  describe("pausing", function ()
    it("should disable those components", function ()
      pauser.pause(components)
  
      assert.is.falsy(components.animation.player.enabled)
      assert.is.falsy(components.gravitational.player.enabled)
      assert.is.falsy(components.velocity.player.enabled)
    end)

    describe("and then unpausing", function ()
      it("should enable the previously enabled components", function ()
        pauser.unpause(components)
    
        assert.is.truthy(components.animation.player.enabled)
        assert.is.falsy(components.gravitational.player.enabled)
        assert.is.truthy(components.velocity.player.enabled)
      end)
    end)
  end)
end)
