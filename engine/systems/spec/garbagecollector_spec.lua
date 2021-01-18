local garbagecollector

before_each(function ()
  garbagecollector = require "engine.systems.garbagecollector"
end)

after_each(function ()
  package.loaded["engine.systems.garbagecollector"] = nil
end)

describe("Loading an entity that is marked as garbage", function ()
  local components

  before_each(function ()
    components = {
      garbage = {
        markedEntity = true,
        nonMarkedEntity = false
      },
      position = {
        markedEntity = {
          x = 45,
          y = 289
        },
        nonMarkedEntity = {
          x = 40,
          y = 270
        }
      },
      collectable = {
        markedEntity = true
      },
      collisionBox = {
        markedEntity = {
          origin = {
            x = 25,
            y = 25
          },
          width = 50,
          height = 50,
          x = 45,
          y = 289
        },
        nonMarkedEntity = {
          origin = {
            x = 20,
            y = 135
          },
          width = 70,
          height = 100,
          x = 40,
          y = 270
        }
      }
    }

    garbagecollector.update(components)
  end)

  it("should remove all of its components", function ()
    assert.is.falsy(components.garbage.markedEntity)
    assert.is.falsy(components.position.markedEntity)
    assert.is.falsy(components.collectable.markedEntity)
    assert.is.falsy(components.collisionBox.markedEntity)
  end)

  it("should not remove components from other entities", function ()
    assert.is.truthy(components.position.nonMarkedEntity)
    assert.is.truthy(components.collisionBox.nonMarkedEntity)
  end)
end)
