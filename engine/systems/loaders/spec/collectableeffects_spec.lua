local collectableEffects

before_each(function ()
  collectableEffects = require "engine.systems.loaders.collectableeffects"
end)

after_each(function ()
  package.loaded["engine.systems.loaders.collectableeffects"] = nil
end)

describe("loading a config", function ()
  it("should create an empty collectable effects table", function ()
    local emptyConfig = {}
    
    local loadedCollectableEffects = collectableEffects.load(emptyConfig)

    assert.are.same({}, loadedCollectableEffects)
  end)
end)
