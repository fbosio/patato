local resourcemanager

before_each(function ()
  resourcemanager = require "engine.resourcemanager"
  local loveMock = {graphics = {}}
  function loveMock.graphics.getDimensions()
    return 800, 600
  end
  resourcemanager.load(loveMock)
end)

after_each(function ()
  package.loaded.resourcemanager = nil
end)

describe("Load an empty config", function ()
  local emptyConfig = {}
  local loadedEmptyConfig

  before_each(function ()
    emptyConfig = {}
    loadedEmptyConfig = resourcemanager.buildWorld(emptyConfig)
  end)
  
  it("should load a world with zero gravity", function ()
    assert.are.same(0, loadedEmptyConfig.world.gravity)
  end)

  it("should map ASWD keys", function ()
    assert.are.same("a", loadedEmptyConfig.keys.left)
    assert.are.same("d", loadedEmptyConfig.keys.right)
    assert.are.same("w", loadedEmptyConfig.keys.up)
    assert.are.same("s", loadedEmptyConfig.keys.down)
  end)
end)

describe("Load an empty world", function ()
  it("should load a world with zero gravity", function ()
    local config = {world = {}}

    local loadedConfig = resourcemanager.buildWorld(config)

    assert.are.same(0, loadedConfig.world.gravity)
  end)
end)

describe("Load world with gravity", function ()
  it("should copy the defined world", function ()
    local config = {
      world = {
        gravity = 500
      }
    }

    local loadedConfig = resourcemanager.buildWorld(config)

    assert.are.same(500, loadedConfig.world.gravity)
  end)
end)

describe("Load an empty keys structure", function ()
  it("should load a world with default movement keys", function ()
    local config = {keys = {}}

    local loadedConfig = resourcemanager.buildWorld(config)

    assert.are.same("a", loadedConfig.keys.left)
    assert.are.same("d", loadedConfig.keys.right)
    assert.are.same("w", loadedConfig.keys.up)
    assert.are.same("s", loadedConfig.keys.down)
  end)
end)

describe("Load all movement keys", function ()
  it("should copy the defined keys", function ()
    local config = {
      keys = {
        left = "j",
        right = "l",
        up = "i",
        down = "k"
      }
    }

    local loadedConfig = resourcemanager.buildWorld(config)

    assert.are.same("j", loadedConfig.keys.left)
    assert.are.same("l", loadedConfig.keys.right)
    assert.are.same("i", loadedConfig.keys.up)
    assert.are.same("k", loadedConfig.keys.down)
  end)
end)

describe("Load some movement keys", function ()
  it("should fill lacking keys with default values", function ()
    local config = {
      keys = {
        left = "j",
        down = "k"
      }
    }

    local loadedConfig = resourcemanager.buildWorld(config)

    assert.are.same("j", loadedConfig.keys.left)
    assert.are.same("d", loadedConfig.keys.right)
    assert.are.same("w", loadedConfig.keys.up)
    assert.are.same("k", loadedConfig.keys.down)
  end)
end)

describe("Load some non movement keys", function ()
  it("should copy the defined keys to resourcemanager", function ()
    local config = {
      keys = {
        ["super cool action 1"] = "j",
        ["super cool action 2"] = "k"
      }
    }

    local loadedConfig = resourcemanager.buildWorld(config)

    assert.are.same("j", loadedConfig.keys["super cool action 1"])
    assert.are.same("k", loadedConfig.keys["super cool action 2"])
  end)
end)

describe("Load an empty entities list", function ()
  it("should create an empty game state", function ()
    local config = {
      entities = {}
    }

    local loadedConfig = resourcemanager.buildWorld(config)

    assert.are.same({}, loadedConfig.gameState)
  end)
end)

describe("Load an entity without components", function ()
  it("should create an empty game state", function ()
    local config = {
      entities = {
        player = {}
      }
    }

    local loadedConfig = resourcemanager.buildWorld(config)

    assert.are.same({}, loadedConfig.gameState)
  end)
end)

describe("Load an entity with an empty input", function ()
  local config
  before_each(function ()
    config = {
      entities = {
        player = {
          input = {}
        }
      }
    }
  end)

  it("should create game state with input as default keys", function ()
    local loadedConfig = resourcemanager.buildWorld(config)

    local playerInput = loadedConfig.gameState.input.player
    assert.are.same("left", playerInput.walkLeft)
    assert.are.same("right", playerInput.walkRight)
    assert.are.same("up", playerInput.walkUp)
    assert.are.same("down", playerInput.walkDown)
  end)

  it("should create game state with default walk speed", function ()
    local loadedConfig = resourcemanager.buildWorld(config)

    assert.are.same(400, loadedConfig.gameState.impulseSpeed.player.walk)
  end)

  it("should create game state with default position", function ()
    local loadedConfig = resourcemanager.buildWorld(config)

    local playerPosition = loadedConfig.gameState.position.player
    assert.are.same(400, playerPosition.x)
    assert.are.same(300, playerPosition.y)
  end)

  it("should create game state with default velocity", function ()
    local loadedConfig = resourcemanager.buildWorld(config)

    local playerVelocity = loadedConfig.gameState.velocity.player
    assert.are.same(0, playerVelocity.x)
    assert.are.same(0, playerVelocity.y)
  end)
end)

describe("Load an entity with movement input and lacking keys", function ()
  it("should copy the defined keys and ignore the rest", function ()
    local config = {
      keys = {
        left2 = "j",
        right2 = "l",
        down2 = "k"
      },
      entities = {
        player = {
          input = {
            walkLeft = "left2",
            walkRight = "right2",
            walkUp = "up2",
            walkDown = "down2"
          }
        }
      }
    }

    local loadedConfig = resourcemanager.buildWorld(config)

    local playerInput = loadedConfig.gameState.input.player
    assert.are.same("left2", playerInput.walkLeft)
    assert.are.same("right2", playerInput.walkRight)
    assert.is.falsy(playerInput.walkUp)
    assert.are.same("down2", playerInput.walkDown)
  end)
end)

describe("Load an entity with lacking movement input", function ()
  it("should not set lacking input", function ()
    local config = {
      entities = {
        player = {
          input = {
            walkLeft = "left"
          }
        }
      }
    }

    local loadedConfig = resourcemanager.buildWorld(config)

    assert.are.falsy(loadedConfig.gameState.input.player.walkRight)
  end)
end)

describe("Load an entity with movement input and keys", function ()
  it("should copy the defined keys to the component", function ()
    local config = {
      keys = {
        left2 = "j",
        right2 = "l",
        up2 = "i",
        down2 = "k"
      },
      entities = {
        player = {
          input = {
            walkLeft = "left2",
            walkRight = "right2",
            walkUp = "up2",
            walkDown = "down2"
          }
        }
      }
    }

    local loadedConfig = resourcemanager.buildWorld(config)

    local playerInput = loadedConfig.gameState.input.player
    assert.are.same("left2", playerInput.walkLeft)
    assert.are.same("right2", playerInput.walkRight)
    assert.are.same("up2", playerInput.walkUp)
    assert.are.same("down2", playerInput.walkDown)
  end)
end)

describe("Load an entity with only an empty speed list", function ()
  it("should create an empty game state", function ()
    local config = {
      entities = {
        player = {
          impulseSpeed = {}
        }
      }
    }

    local loadedConfig = resourcemanager.buildWorld(config)

    assert.are.same({}, loadedConfig.gameState)
  end)
end)

describe("Load an entity with impulse speeds", function ()
  it("should copy the define speeds to the component", function ()
    local config = {
      entities = {
        player = {
          impulseSpeed = {
            walk = 400,
            crouchWalk = 200,
            jump = 1200,
            climb = 400
          }
        }
      }
    }

    local loadedConfig = resourcemanager.buildWorld(config)

    local playerSpeed = loadedConfig.gameState.impulseSpeed.player
    assert.are.same(400, playerSpeed.walk)
    assert.are.same(200, playerSpeed.crouchWalk)
    assert.are.same(1200, playerSpeed.jump)
    assert.are.same(400, playerSpeed.climb)
  end)
end)
