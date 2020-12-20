local garbagecollector

before_each(function ()
  garbagecollector = require "engine.systems.garbagecollector"
end)

after_each(function ()
  package.loaded.garbagecollector = nil
end)

describe("Loading an entity that is marked as garbage", function ()
  it("should remove all of its components", function ()
    local gameState = {
      garbage = {
        markedEntity = true
      },
      position = {
        markedEntity = {
          x = 45,
          y = 289
        }
      },
      collectable = {
        markedEntity = true
      },
      collisionBox = {
        markedEntity = {
          origin = {
            x = 35,
            y = 100
          },
          width = 70,
          height = 100,
          x = 45,
          y = 289
        }
      }
    }

    garbagecollector.update(gameState)

    assert.is.falsy(gameState.garbage.markedEntity)
    assert.is.falsy(gameState.position.markedEntity)
    assert.is.falsy(gameState.collectable.markedEntity)
    assert.is.falsy(gameState.collisionBox.markedEntity)
  end)
end)
