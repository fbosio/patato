local engine = require "engine"

describe("Load with empty config", function ()
  it("should load a world with zero gravity", function ()
    config = ""

    engine.load(config)

    assert.are.same(0, engine.world.gravity)
  end)
end)

describe("Load with empty world", function ()
  it("should load a world with zero gravity", function ()
    config = "world:"

    engine.load(config)

    assert.are.same(0, engine.world.gravity)
  end)
end)

describe("Load with world with gravity", function ()
  it("should copy the loaded world", function ()
    config = [[
      world:
        gravity: 500
    ]]

    engine.load(config)

    assert.are.same(500, engine.world.gravity)
  end)
end)
