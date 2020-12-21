local messenger

before_each(function ()
  messenger = require "engine.systems.messenger"
end)

after_each(function ()
  package.loaded["engine.systems.messenger"] = nil
end)

describe("loading a collector that collides with a collectable", function ()
  it("should remove the collectable", function ()
    local collectors = {
      mario = true
    }
    local collectables = {
      coin = {name = "coin"}
    }
    local collisionBoxes = {
      mario = {
        origin = {x = 16, y = 64},
        x = 100,
        y = 300,
        width = 32,
        height = 64
      },
      coin = {
        origin = {x = 16, y = 32},
        x = 108,
        y = 300,
        width = 32,
        height = 32
      }
    }
    local collectableEffects = {
      coin = function () end
    }
    local garbage = {}

    messenger.update(collectors, collectables, collectableEffects,
                     collisionBoxes, garbage)

    assert.are.truthy(garbage.coin)
  end)
end)
