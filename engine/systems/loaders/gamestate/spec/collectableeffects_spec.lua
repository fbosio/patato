local loader

before_each(function ()
  loader = require "engine.systems.loaders.gamestate.collectableeffects"
end)

after_each(function ()
  package.loaded["engine.systems.loaders.gamestate.collectableeffects"] = nil
end)

describe("loading itself", function ()
  it("should create an empty collectable effects table", function ()
    local loadedCollectableEffects = loader.load()

    assert.are.same({}, loadedCollectableEffects)
  end)
end)
