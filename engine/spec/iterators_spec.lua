local iterators

before_each(function ()
  iterators = require "engine.iterators"
end)

after_each(function ()
  package.loaded["engine.iterators"] = nil
end)

describe("with climber component and its dependencies", function ()
  it("should yield entity, climber and its dependencies", function ()
    local components = {
      climber = {
        spiderman = true
      },
      collisionBox = {
        spiderman = {
          x = 0,
          y = 0,
          width = 32,
          height = 64,
          origin = {x = 16, y = 64}
        }
      },
      gravitational = {
        spiderman = {enabled = true}
      },
      velocity = {
        spiderman = {x = 50, y = -100},
        cloud = {x = 3000, y = 0},
        sky = {x = 0, y = 0}
      },
      position = {
        spiderman = {x = 100, y = -50},
        cloud = {x = 30, y = 40},
        sky = {x = -128, y = -37}
      }
    }
    
    local result = {}
    for k, _ in pairs(components) do result[k] = {} end
    for entity, c, cb, g, v, p in iterators.climber(components) do
      result.climber[entity] = c
      result.collisionBox[entity] = cb
      result.gravitational[entity] = g
      result.velocity[entity] = v
      result.position[entity] = p
    end

    assert.are.same(components.climber, result.climber)
    assert.are.same(components.collisionBox, result.collisionBox)
    assert.are.same(components.gravitational, result.gravitational)
    assert.are.same({spiderman = components.velocity.spiderman},
                    result.velocity)
    assert.are.same({spiderman = components.position.spiderman},
                    result.position)
  end)
end)
