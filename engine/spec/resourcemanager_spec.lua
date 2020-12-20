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
  local emptyWorld

  before_each(function ()
    emptyConfig = {}
    emptyWorld = resourcemanager.buildWorld(emptyConfig)
  end)

  it("should load physics with zero gravity", function ()
    assert.are.same(0, emptyWorld.physics.gravity)
  end)

  it("should map ASWD keys", function ()
    assert.are.same("a", emptyWorld.keys.left)
    assert.are.same("d", emptyWorld.keys.right)
    assert.are.same("w", emptyWorld.keys.up)
    assert.are.same("s", emptyWorld.keys.down)
  end)
end)

describe("Load an empty physics table", function ()
  it("should load physics with zero gravity", function ()
    local config = {physics = {}}

    local world = resourcemanager.buildWorld(config)

    assert.are.same(0, world.physics.gravity)
  end)
end)

describe("Load gravity", function ()
  it("should copy the defined physics", function ()
    local config = {
      physics = {
        gravity = 500
      }
    }

    local world = resourcemanager.buildWorld(config)

    assert.are.same(500, world.physics.gravity)
  end)
end)

describe("Load an empty keys structure", function ()
  it("should load a physics with default movement keys", function ()
    local config = {keys = {}}

    local world = resourcemanager.buildWorld(config)

    assert.are.same("a", world.keys.left)
    assert.are.same("d", world.keys.right)
    assert.are.same("w", world.keys.up)
    assert.are.same("s", world.keys.down)
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

    local world = resourcemanager.buildWorld(config)

    assert.are.same("j", world.keys.left)
    assert.are.same("l", world.keys.right)
    assert.are.same("i", world.keys.up)
    assert.are.same("k", world.keys.down)
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

    local world = resourcemanager.buildWorld(config)

    assert.are.same("j", world.keys.left)
    assert.are.same("d", world.keys.right)
    assert.are.same("w", world.keys.up)
    assert.are.same("k", world.keys.down)
  end)
end)

describe("Load some keys that are not for movement", function ()
  it("should copy the defined keys to resourcemanager", function ()
    local config = {
      keys = {
        ["super cool action 1"] = "j",
        ["super cool action 2"] = "k"
      }
    }

    local world = resourcemanager.buildWorld(config)

    assert.are.same("j", world.keys["super cool action 1"])
    assert.are.same("k", world.keys["super cool action 2"])
  end)
end)

describe("Load an empty entities list", function ()
  it("should create an empty game state", function ()
    local config = {
      entities = {}
    }

    local world = resourcemanager.buildWorld(config)

    assert.are.same({}, world.gameState)
  end)
end)

describe("Load an entity without components", function ()
  it("should create an empty game state", function ()
    local config = {
      entities = {
        player = {}
      }
    }

    local world = resourcemanager.buildWorld(config)

    assert.are.same({}, world.gameState)
  end)
end)

describe("Load an entity with a nonexistent component", function ()
  it("should throw an error", function ()
    local config = {
      entities = {
        player = {
          someWeirdThingWithAVeryAnnoyingName = "Gloryhallastoopid"
        }
      }
    }

    assert.has_error(function () resourcemanager.buildWorld(config) end)
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
    local world = resourcemanager.buildWorld(config)

    local playerInput = world.gameState.input.player
    assert.are.same("left", playerInput.walkLeft)
    assert.are.same("right", playerInput.walkRight)
    assert.are.same("up", playerInput.walkUp)
    assert.are.same("down", playerInput.walkDown)
  end)

  it("should create game state with default walk speed", function ()
    local world = resourcemanager.buildWorld(config)

    assert.are.same(400, world.gameState.impulseSpeed.player.walk)
  end)

  it("should create game state with default position", function ()
    local world = resourcemanager.buildWorld(config)

    local playerPosition = world.gameState.position.player
    assert.are.same(400, playerPosition.x)
    assert.are.same(300, playerPosition.y)
  end)

  it("should create game state with default velocity", function ()
    local world = resourcemanager.buildWorld(config)

    local playerVelocity = world.gameState.velocity.player
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

    local world = resourcemanager.buildWorld(config)

    local playerInput = world.gameState.input.player
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

    local world = resourcemanager.buildWorld(config)

    assert.is.falsy(world.gameState.input.player.walkRight)
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

    local world = resourcemanager.buildWorld(config)

    local playerInput = world.gameState.input.player
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

    local world = resourcemanager.buildWorld(config)

    assert.are.same({}, world.gameState)
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

    local world = resourcemanager.buildWorld(config)

    local playerSpeed = world.gameState.impulseSpeed.player
    assert.are.same(400, playerSpeed.walk)
    assert.are.same(200, playerSpeed.crouchWalk)
    assert.are.same(1200, playerSpeed.jump)
    assert.are.same(400, playerSpeed.climb)
  end)
end)

describe("Load config with nonempty menu", function ()
  it("should copy the menu", function ()
    local config = {
      entities = {
        mainMenu = {
          menu = {
            options = {"Start"}
          }
        }
      }
    }

    local world = resourcemanager.buildWorld(config)

    assert.are.same({"Start"}, world.gameState.menu.mainMenu.options)
  end)

end)

describe("Load config with nonempty menu and other entities", function ()
  local config, world

  before_each(function ()
    config = {
      entities = {
        playerOne = {
          input = {}
        },
        playerTwo = {
          input = {}
        },
        mainMenu = {
          input = {},
          menu = {
            options = {"Start"}
          }
        }
      }
    }
    world = resourcemanager.buildWorld(config)
  end)

  it("should load components with menu entity", function ()
    assert.are.same({"Start"}, world.gameState.menu.mainMenu.options)
    assert.are.truthy(world.gameState.input.mainMenu)
  end)

  it("should copy menu with default input", function ()
    local menuInput = world.gameState.input.mainMenu
    assert.are.same("up", menuInput.menuPrevious)
    assert.are.same("down", menuInput.menuNext)
  end)

  it("should not copy entities that have not the menu component", function ()
    assert.is.falsy(world.gameState.input.playerOne)
    assert.is.falsy(world.gameState.input.playerTwo)
    assert.is.falsy(world.gameState.position)
  end)
end)

describe("Load entities and an empty levels table", function ()
  it("should not copy the entities", function ()
    local config = {
      entities = {
        player = {
          input = {}
        }
      },
      levels = {}
    }

    local world = resourcemanager.buildWorld(config)

    assert.is.falsy(world.gameState.input)
  end)
end)

describe("Load a level with defined entity and position", function ()
  it("should copy that entity with that position", function ()
    local config = {
      entities = {
        sonic = {
          input = {}
        }
      },
      levels = {
        ["green hill zone"] = {
          sonic = {200, 300}
        }
      }
    }

    local world = resourcemanager.buildWorld(config)

    assert.is.truthy(world.gameState.input.sonic)
    assert.are.same(200, world.gameState.position.sonic.x)
    assert.are.same(300, world.gameState.position.sonic.y)
  end)
end)

describe("Load two levels and the name of the first one", function ()
  it("should start the game in the first level", function ()
    local config = {
      entities = {
        sonic = {
          input = {}
        }
      },
      levels = {
        ["metropolis zone"] = {
          sonic = {735, 97}
        },
        ["green hill zone"] = {
          sonic = {200, 300}
        }
      },
      firstLevel = "green hill zone"
    }

    local world = resourcemanager.buildWorld(config)

    assert.is.truthy(world.gameState.input.sonic)
    assert.are.same(200, world.gameState.position.sonic.x)
    assert.are.same(300, world.gameState.position.sonic.y)
  end)
end)

describe("Loading a collector entity", function ()
  it("should copy the component", function ()
    local config = {
      entities = {
        player = {
          collector = true
        }
      }
    }

    local world = resourcemanager.buildWorld(config)

    assert.is.truthy(world.gameState.collector.player)
  end)
end)

describe("Loading a collectable entity", function ()
  it("should copy the component", function ()
    local config = {
      entities = {
        item = {
          collectable = true
        }
      }
    }

    local world = resourcemanager.buildWorld(config)

    assert.is.truthy(world.gameState.collectable.item)
  end)
end)

describe("Loading an entity that is both collector and collectable", function ()
  it("should throw an error", function ()
    local config = {
      entities = {
        absurdSpecimen = {
          collector = true,
          collectable = true
        }
      }
    }

    assert.has_error(function () resourcemanager.buildWorld(config) end)
  end)
end)

describe("Loading a collision box", function ()
  local config

  before_each(function ()
     config = {
      entities = {
        player = {
          collisionBox = {-15, -35, 30, 70}
        }
      }
    }
  end)

  it("should copy the component", function ()
    local world = resourcemanager.buildWorld(config)

    local box = world.gameState.collisionBox.player
    assert.are.same(-15, box.x)
    assert.are.same(-35, box.y)
    assert.are.same(30, box.width)
    assert.are.same(70, box.height)
  end)

  it("should create game state with default position", function ()
    local world = resourcemanager.buildWorld(config)

    local playerPosition = world.gameState.position.player
    assert.are.same(400, playerPosition.x)
    assert.are.same(300, playerPosition.y)
  end)
end)
