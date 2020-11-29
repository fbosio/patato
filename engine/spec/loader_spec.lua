local loader

before_each(function ()
  loader = require "engine.loader"
  local loveMock = {graphics = {}}
  function loveMock.graphics.getDimensions()
    return 800, 600
  end
  loader.init(loveMock)
end)

after_each(function ()
  package.loaded.loader = nil
end)

describe("Load an empty config", function ()
  it("should load a world with zero gravity", function ()
    local config = ""

    local loadedConfig = loader.loadFromString(config)

    assert.are.same(0, loadedConfig.world.gravity)
  end)

  it("should map ASWD keys", function ()
    local config = ""

    local loadedConfig = loader.loadFromString(config)

    assert.are.same("a", loadedConfig.keys.left)
    assert.are.same("d", loadedConfig.keys.right)
    assert.are.same("w", loadedConfig.keys.up)
    assert.are.same("s", loadedConfig.keys.down)
  end)
end)

describe("Load an empty world", function ()
  it("should load a world with zero gravity", function ()
    local config = "world:"

    local loadedConfig = loader.loadFromString(config)

    assert.are.same(0, loadedConfig.world.gravity)
  end)
end)

describe("Load world with gravity", function ()
  it("should copy the defined world", function ()
    local config = [[
      world:
        gravity: 500
    ]]

    local loadedConfig = loader.loadFromString(config)

    assert.are.same(500, loadedConfig.world.gravity)
  end)
end)

describe("Load an empty keys structure", function ()
  it("should load a world with default movement keys", function ()
    local config = "keys:"

    local loadedConfig = loader.loadFromString(config)

    assert.are.same("a", loadedConfig.keys.left)
    assert.are.same("d", loadedConfig.keys.right)
    assert.are.same("w", loadedConfig.keys.up)
    assert.are.same("s", loadedConfig.keys.down)
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

    local loadedConfig = loader.loadFromString(config)

    assert.are.same("j", loadedConfig.keys.left)
    assert.are.same("l", loadedConfig.keys.right)
    assert.are.same("i", loadedConfig.keys.up)
    assert.are.same("k", loadedConfig.keys.down)
  end)
end)

describe("Load some movement keys", function ()
  it("should fill lacking keys with default values", function ()
    local config = [[
      keys:
        left: j
        down: k
    ]]

    local loadedConfig = loader.loadFromString(config)

    assert.are.same("j", loadedConfig.keys.left)
    assert.are.same("d", loadedConfig.keys.right)
    assert.are.same("w", loadedConfig.keys.up)
    assert.are.same("k", loadedConfig.keys.down)
  end)
end)

describe("Load some non movement keys", function ()
  it("should copy the defined keys to loader", function ()
    local config = [[
      keys:
        super cool action 1: j
        super cool action 2: k
    ]]

    local loadedConfig = loader.loadFromString(config)

    assert.are.same("j", loadedConfig.keys["super cool action 1"])
    assert.are.same("k", loadedConfig.keys["super cool action 2"])
  end)
end)

describe("Load an empty entities list", function ()
  it("should create an empty game state", function ()
    local config = [[
      entities:
    ]]

    local loadedConfig = loader.loadFromString(config)

    assert.are.same({}, loadedConfig.gameState)
  end)
end)

describe("Load an entity without components", function ()
  it("should create an empty game state", function ()
    local config = [[
      entities:
        player:
    ]]

    local loadedConfig = loader.loadFromString(config)

    assert.are.same({}, loadedConfig.gameState)
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
    local loadedConfig = loader.loadFromString(config)

    local playerInput = loadedConfig.gameState.input.player
    assert.are.same("left", playerInput.left)
    assert.are.same("right", playerInput.right)
    assert.are.same("up", playerInput.up)
    assert.are.same("down", playerInput.down)
  end)

  it("should create game state with default walk speed", function ()
    local loadedConfig = loader.loadFromString(config)

    assert.are.same(400, loadedConfig.gameState.impulseSpeed.player.walk)
  end)

  it("should create game state with default position", function ()
    local loadedConfig = loader.loadFromString(config)

    local playerPosition = loadedConfig.gameState.position.player
    assert.are.same(400, playerPosition.x)
    assert.are.same(300, playerPosition.y)
  end)

  it("should create game state with default velocity", function ()
    local loadedConfig = loader.loadFromString(config)

    local playerVelocity = loadedConfig.gameState.velocity.player
    assert.are.same(0, playerVelocity.x)
    assert.are.same(0, playerVelocity.y)
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

    local loadedConfig = loader.loadFromString(config)

    local playerInput = loadedConfig.gameState.input.player
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

    local loadedConfig = loader.loadFromString(config)

    local playerInput = loadedConfig.gameState.input.player
    assert.are.same("left2", playerInput.left)
    assert.are.same("right2", playerInput.right)
    assert.are.same("up2", playerInput.up)
    assert.are.same("down2", playerInput.down)
  end)
end)

describe("Load an entity with only an empty speed list", function ()
  it("should create an empty game state", function ()
    local config = [[
      entities:
        player:
          impulseSpeed:
    ]]

    local loadedConfig = loader.loadFromString(config)

    assert.are.same({}, loadedConfig.gameState)
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

    local loadedConfig = loader.loadFromString(config)

    local playerSpeed = loadedConfig.gameState.impulseSpeed.player
    assert.are.same(400, playerSpeed.walk)
    assert.are.same(200, playerSpeed.crouchWalk)
    assert.are.same(1200, playerSpeed.jump)
    assert.are.same(400, playerSpeed.climb)
  end)
end)
