local collection

before_each(function ()
  collection = require "engine.systems.messengers.collection"
end)

after_each(function ()
  package.loaded["engine.systems.messengers.collection"] = nil
end)

describe("loading a collector that collides with a collectable", function ()
  local components, collectableEffects
  before_each(function ()
    components = {
      collector = {
        mario = {enabled = true}
      },
      collectable = {
        coin = {name = "coin"}
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
    collectableEffects = {
      coin = function () end
    }
  end)

  describe("and the collector is enabled", function ()
    it("should remove the collectable", function ()
      collection.update(components, collectableEffects)
      
      assert.are.truthy(components.garbage.coin)
    end)
  end)

  describe("and the collector is disabled", function ()
    it("should keep the collectable", function ()
      components.collector.mario.enabled = false

      collection.update(components, collectableEffects)
      
      assert.are.falsy(components.garbage.coin)
    end)
  end)
end)
