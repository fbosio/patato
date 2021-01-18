local collection

before_each(function ()
  collection = require "engine.systems.messengers.collection"
end)

after_each(function ()
  package.loaded["engine.systems.messengers.collection"] = nil
end)

describe("loading a collector that collides with a collectable", function ()
  it("should remove the collectable", function ()
    local components = {
      collector = {
        mario = true
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
    local collectableEffects = {
      coin = function () end
    }

    collection.update(components, collectableEffects)

    assert.are.truthy(components.garbage.coin)
  end)
end)
