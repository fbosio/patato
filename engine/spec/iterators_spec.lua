local iterators

before_each(function ()
  iterators = require "engine.iterators"
end)

after_each(function ()
  package.loaded["engine.iterators"] = nil
end)

describe("", function ()
  it("", function ()
    local components = {
      velocity = {
        ball = {x = 50, y = -100},
        cloud = {x = 3000, y = 0},
        sky = {x = 0, y = 0}
      },
      position = {
        ball = {x = 100, y = -50},
        cloud = {x = 30, y = 40},
        sky = {x = -128, y = -37}
      }
    }
    
    local result = {position = {}, velocity = {}}
    for entity, velocity, position in iterators.velocity(components) do
      result.velocity[entity] = velocity
      result.position[entity] = position
    end

    assert.are.same(components, result)
  end)
end)
