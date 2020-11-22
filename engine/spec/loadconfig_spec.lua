describe("Load with empty config", function ()
  local engine = require "engine"

  it("should work without crashing", function ()
    config = {}
    config_mock = mock(config)

    local status = engine.load(config_mock)

    local codeOk = 0
    assert.are.equals(codeOk, status)
  end)
end)
