local dt = 1 / 70
local transporter, components

before_each(function ()
  transporter = require "engine.systems.transporter"
  components = {
    velocity = {},
    position = {}
  }
end)

after_each(function ()
  package.loaded["engine.systems.transporter"] = nil
end)

describe("with empty velocity and position tables", function ()
  it("should keep those tables empty", function ()
    transporter.move(dt, components)

    assert.are.same(components.velocity, {})
    assert.are.same(components.position, {})
  end)
end)

describe("receiving an entity with nonzero velocity", function ()
  it("should update its position", function ()
    components.velocity = {
      player = {
        x = 140,
        y = -70
      }
    }
    components.position = {
      player = {
        x = -397,
        y = 254
      }
    }
    
    transporter.move(dt, components)

    assert.are.same({x = -395, y = 253}, components.position.player)
  end)
end)

describe("receiving gravity and a enabled gravitational entity", function ()
  it("should upate the velocity of the entity", function ()
    components.velocity = {
      anvil = {
        x = 0,
        y = 0
      }
    }
    local gravity = 7000
    components.gravitational = {
      anvil = {enabled = true}
    }
    
    transporter.drag(dt, components, gravity)

    assert.are.same(100, components.velocity.anvil.y)
  end)
end)

describe("receiving gravity and a disabled gravitational entity", function ()
  it("should update the velocity of the entity", function ()
    local gravity = 7000
    components.velocity = {
      anvil = {
        x = 0,
        y = 0
      }
    }
    components.gravitational = {
      anvil = {enabled = false}
    }
    
    transporter.drag(dt, components, gravity)

    assert.are.same(0, components.velocity.anvil.y)
  end)
end)
