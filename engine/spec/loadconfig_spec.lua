local engine

before_each(function ()
  engine = require "engine"
end)

after_each(function ()
  package.loaded.engine = nil
end)

describe("Load an empty config", function ()
  it("should load a world with zero gravity", function ()
    local config = ""

    engine.loadFromString(config)

    assert.are.same(0, engine.world.gravity)
  end)

  it("should map ASWD keys", function ()
    local config = ""

    engine.loadFromString(config)

    assert.are.same("a", engine.keys.left)
    assert.are.same("d", engine.keys.right)
    assert.are.same("w", engine.keys.up)
    assert.are.same("s", engine.keys.down)
  end)
end)

describe("Load an empty world", function ()
  it("should load a world with zero gravity", function ()
    local config = "world:"

    engine.loadFromString(config)

    assert.are.same(0, engine.world.gravity)
  end)
end)

describe("Load world with gravity", function ()
  it("should copy the defined world", function ()
    local config = [[
      world:
        gravity: 500
    ]]

    engine.loadFromString(config)

    assert.are.same(500, engine.world.gravity)
  end)
end)

describe("Load an empty keys structure", function ()
  it("should load a world with default movement keys", function ()
    local config = "keys:"

    engine.loadFromString(config)

    assert.are.same("a", engine.keys.left)
    assert.are.same("d", engine.keys.right)
    assert.are.same("w", engine.keys.up)
    assert.are.same("s", engine.keys.down)
  end)
end)

describe("Load all movement keys", function ()
  local config

  it("should copy the defined keys", function ()
    local config = [[
      keys:
        left: j
        right: l
        up: i
        down: k
    ]]

    engine.loadFromString(config)

    assert.are.same("j", engine.keys.left)
    assert.are.same("l", engine.keys.right)
    assert.are.same("i", engine.keys.up)
    assert.are.same("k", engine.keys.down)
  end)
end)

describe("Load some movement keys", function ()
  it("should fill lacking keys with default values", function ()
    local config = [[
      keys:
        left: j
        down: k
    ]]

    engine.loadFromString(config)

    assert.are.same("j", engine.keys.left)
    assert.are.same("d", engine.keys.right)
    assert.are.same("w", engine.keys.up)
    assert.are.same("k", engine.keys.down)
  end)
end)

describe("Load some non movement keys", function ()
  it("should copy the defined keys to engine", function ()
    local config = [[
      keys:
        super cool action 1: j
        super cool action 2: k
    ]]

    engine.loadFromString(config)

    assert.are.same("j", engine.keys["super cool action 1"])
    assert.are.same("k", engine.keys["super cool action 2"])
  end)
end)

describe("Load an empty entities list", function ()
  it("should not create game state", function ()
    local config = [[
      entities:
    ]]

    engine.loadFromString(config)

    assert.is.falsy(engine.gameState)
  end)
end)

describe("Load an entity without components", function ()
  it("should not create game state", function ()
    local config = [[
      entities:
        player:
    ]]

    engine.loadFromString(config)

    assert.is.falsy(engine.gameState)
  end)
end)

describe("Load an entity with an empty input", function ()
  local config
  before_each(function ()
    config = [[
      entities:
        player:
          input:
    ]]
  end)

  it("should create game state with input as default keys", function ()
    engine.loadFromString(config)

    local playerInput = engine.gameState.input.player
    assert.are.same("left", playerInput.left)
    assert.are.same("right", playerInput.right)
    assert.are.same("up", playerInput.up)
    assert.are.same("down", playerInput.down)
  end)

  it("should create game state with default walk speed", function ()
    engine.loadFromString(config)

    assert.are.same(400, engine.gameState.impulseSpeed.player.walk)
  end)

  it("should create game state with default position", function ()
    engine.loadFromString(config)

    local playerPosition = engine.gameState.position.player
    assert.are.same(0, playerPosition.x)
    assert.are.same(0, playerPosition.y)
  end)
end)

describe("Load an entity with movement input and lacking keys", function ()
  it("should copy the defined keys and ignore the rest", function ()
    local config = [[
      keys:
        left2: j
        right2: l
        down2: k
      entities:
        player:
          input:
            left: left2
            right: right2
            up: up2
            down: down2
    ]]

    engine.loadFromString(config)

    local playerInput = engine.gameState.input.player
    assert.are.same("left2", playerInput.left)
    assert.are.same("right2", playerInput.right)
    assert.is.falsy(playerInput.up)
    assert.are.same("down2", playerInput.down)
  end)
end)

describe("Load an entity with movement input and keys", function ()
  it("should copy the defined keys to the component", function ()
    local config = [[
      keys:
        left2: j
        right2: l
        up2: i
        down2: k
      entities:
        player:
          input:
            left: left2
            right: right2
            up: up2
            down: down2
    ]]

    engine.loadFromString(config)

    local playerInput = engine.gameState.input.player
    assert.are.same("left2", playerInput.left)
    assert.are.same("right2", playerInput.right)
    assert.are.same("up2", playerInput.up)
    assert.are.same("down2", playerInput.down)
  end)
end)

describe("Load an entity with only an empty speed list", function ()
  it("should not create game", function ()
    local config = [[
      entities:
        player:
          impulseSpeed:
    ]]

    engine.loadFromString(config)

    assert.is.falsy(engine.gameState)
  end)
end)

describe("Load an entity with impulse speeds", function ()
  it("should copy the define speeds to the component", function ()
    local config = [[
      entities:
        player:
          impulseSpeed:
            walk: 400
            crouchWalk: 200
            jump: 1200
            climb: 400
    ]]

    engine.loadFromString(config)

    local playerSpeed = engine.gameState.impulseSpeed.player
    assert.are.same(400, playerSpeed.walk)
    assert.are.same(200, playerSpeed.crouchWalk)
    assert.are.same(1200, playerSpeed.jump)
    assert.are.same(400, playerSpeed.climb)
  end)
end)
