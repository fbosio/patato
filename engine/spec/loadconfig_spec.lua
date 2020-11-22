local engine = require "engine"

describe("Load an empty config", function ()
  it("should load a world with zero gravity", function ()
    config = ""

    engine.load(config)

    assert.are.same(0, engine.world.gravity)
  end)

  it("should load a world with ASWD keys", function ()
    config = ""

    engine.load(config)

    assert.are.same("a", engine.keys.left)
    assert.are.same("d", engine.keys.right)
    assert.are.same("w", engine.keys.up)
    assert.are.same("s", engine.keys.down)
  end)
end)

describe("Load an empty world", function ()
  it("should load a world with zero gravity", function ()
    config = "world:"

    engine.load(config)

    assert.are.same(0, engine.world.gravity)
  end)
end)

describe("Load world with gravity", function ()
  it("should copy the defined world", function ()
    config = [[
      world:
        gravity: 500
    ]]

    engine.load(config)

    assert.are.same(500, engine.world.gravity)
  end)
end)

describe("Load an empty keys structure", function ()
  it("should load a world with default movement keys", function ()
    config = "keys:"

    engine.load(config)

    assert.are.same("a", engine.keys.left)
    assert.are.same("d", engine.keys.right)
    assert.are.same("w", engine.keys.up)
    assert.are.same("s", engine.keys.down)
  end)
end)

describe("Load all movement keys", function ()
  it("should copy the defined keys", function ()
    config = [[
      keys:
        left: j
        right: l
        up: i
        down: k
    ]]

    engine.load(config)

    assert.are.same("j", engine.keys.left)
    assert.are.same("l", engine.keys.right)
    assert.are.same("i", engine.keys.up)
    assert.are.same("k", engine.keys.down)
  end)
end)

describe("Load some movement keys", function ()
  it("should fill lacking keys with default values", function ()
    config = [[
      keys:
        left: j
        down: k
    ]]

    engine.load(config)

    assert.are.same("j", engine.keys.left)
    assert.are.same("d", engine.keys.right)
    assert.are.same("w", engine.keys.up)
    assert.are.same("k", engine.keys.down)
  end)
end)
