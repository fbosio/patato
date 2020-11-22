local engine = require "engine"

describe("Load with empty config", function ()
  it("should load a world with zero gravity", function ()
    config = ""
    config_mock = mock(config)

    engine.load(config_mock)

    assert.are.same(0, engine.world.gravity)
  end)
end)

describe("Load with empty world", function ()
  it("should load a world with zero gravity", function ()
    config = "world:"
    config_mock = mock(config)

    engine.load(config_mock)

    assert.are.same(0, engine.world.gravity)
  end)
end)
