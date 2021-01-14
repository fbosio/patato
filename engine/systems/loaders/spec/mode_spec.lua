local mode

before_each(function ()
  mode = require "engine.systems.loaders.mode"
end)

after_each(function ()
  package.loaded["engine.systems.loaders.mode"] = nil
end)

describe("loading a config with a release hoisted flag", function ()
  it("it should copy the flag", function ()
    local config = {release = true}
    
    local inReleaseMode = mode.load(config)

    assert.is.truthy(inReleaseMode)
  end)
end)
