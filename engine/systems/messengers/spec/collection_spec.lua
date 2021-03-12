local collection

before_each(function ()
  collection = require "engine.systems.messengers.collection"
end)

after_each(function ()
  package.loaded["engine.systems.messengers.collection"] = nil
end)

describe("loading two overlapping flaps", function ()
  local components
  before_each(function ()
    components = {
      flap = {
        mario = {enabled = true},
        coin = {enabled = true}
      },
      collisionBox = {
        mario = {
          origin = {x = 16, y = 64},
          width = 32,
          height = 64
        },
        coin = {
          origin = {x = 16, y = 32},
          width = 32,
          height = 32
        }
      },
      position = {
        mario = {
          x = 100,
          y = 300
        },
        coin = {
          x = 108,
          y = 300
        }
      },
      garbage = {}
    }
  end)

  describe("and both flaps are enabled", function ()
    before_each(function ()
      collection.update(components)
    end)

    it("should mark both as overlapped", function ()
      assert.are.same("coin", components.flap.mario.overlap)
      assert.are.same("mario", components.flap.coin.overlap)
    end)

    describe("and then one flap is disabled", function ()
      it("should unmark both flaps", function ()
        components.flap.mario.enabled = false
  
        collection.update(components)
        
        assert.are.falsy(components.flap.mario.overlap)
        assert.are.falsy(components.flap.coin.overlap)
      end)
    end)
  end)

  describe("and one flap is disabled", function ()
    it("should mark no entities", function ()
      components.flap.mario.enabled = false

      collection.update(components)
      
      assert.are.falsy(components.flap.mario.overlap)
      assert.are.falsy(components.flap.coin.overlap)
    end)
  end)
end)
