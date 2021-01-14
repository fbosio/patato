local collectableEffects

before_each(function ()
  collectableEffects = require "engine.systems.loaders.collectableeffects"
end)

after_each(function ()
  package.loaded["engine.systems.loaders.collectableeffects"] = nil
end)

describe("loading itself", function ()
  it("should create an empty collectable effects table", function ()
    local loadedCollectableEffects = collectableEffects.load()

    assert.are.same({}, loadedCollectableEffects)
  end)
end)
