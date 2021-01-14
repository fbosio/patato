local physics

before_each(function ()
  physics = require "engine.systems.loaders.physics"
end)

after_each(function ()
  package.loaded["engine.systems.loaders.physics"] = nil
end)

describe("loading an empty config", function ()
  local emptyConfig = {}
  local loadedPhysics

  before_each(function ()
    emptyConfig = {}
    loadedPhysics = physics.load(emptyConfig)
  end)

  it("should load physics with zero gravity", function ()
    assert.are.same(0, loadedPhysics.gravity)
  end)
end)

describe("loading an empty physics table", function ()
  it("should load physics with zero gravity", function ()
    local config = {physics = {}}

    local loadedPhysics = physics.load(config)

    assert.are.same(0, loadedPhysics.gravity)
  end)
end)

describe("loading gravity", function ()
  it("should copy the defined physics", function ()
    local config = {
      physics = {
        gravity = 500
      }
    }

    local loadedPhysics = physics.load(config)

    assert.are.same(500, loadedPhysics.gravity)
  end)
end)
