local engine = require "engine"

describe("Load with empty config", function ()
  it("should load an empty world", function ()
    config = ""
    config_mock = mock(config)

    engine.load(config_mock)

    assert.are.same({}, engine.world)
  end)
end)
