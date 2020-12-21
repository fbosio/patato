local resourcemanager, loveMock, taggerMock

before_each(function ()
  resourcemanager = require "engine.resourcemanager"

  local love = {graphics = {}}
  function love.graphics.getDimensions()
    return 800, 600
  end
  function love.graphics.newImage()
    return {getDimensions = function () end}
  end
  function love.graphics.newQuad()
  end
  loveMock = mock(love)

  taggerMock = {}
  local id = 0
  local tags = {}
  function taggerMock.tag(name)
    id = id + 1
    tags[name] = id
    return id
  end
  function taggerMock.getId(name)
    return tags[name]
  end
  function taggerMock.getName(entity)
    for k, v in pairs(tags) do
      if v == entity then
        return k
      end
    end
  end

  resourcemanager.load(loveMock, taggerMock)
end)

after_each(function ()
  package.loaded.resourcemanager = nil
  package.loaded.tagger = nil
end)

describe("loading an empty config", function ()
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

  it("should create a garbage component table", function ()
    assert.are.truthy(emptyWorld.gameState.garbage)
  end)
end)

describe("loading an empty physics table", function ()
  it("should load physics with zero gravity", function ()
    local config = {physics = {}}

    local world = resourcemanager.buildWorld(config)

    assert.are.same(0, world.physics.gravity)
  end)
end)

describe("loading gravity", function ()
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

describe("loading an empty keys structure", function ()
  it("should load a physics with default movement keys", function ()
    local config = {keys = {}}

    local world = resourcemanager.buildWorld(config)

    assert.are.same("a", world.keys.left)
    assert.are.same("d", world.keys.right)
    assert.are.same("w", world.keys.up)
    assert.are.same("s", world.keys.down)
  end)
end)

describe("loading all movement keys", function ()
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

describe("loading some movement keys", function ()
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

describe("loading some keys that are not for movement", function ()
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

describe("loading an empty entities list", function ()
  it("should create a game state with a garbage table only", function ()
    local config = {
      entities = {}
    }

    local world = resourcemanager.buildWorld(config)

    assert.are.same({garbage={}}, world.gameState)
  end)
end)

describe("loading an entity without components", function ()
  it("should create a game state with a garbage table only", function ()
    local config = {
      entities = {
        player = {}
      }
    }

    local world = resourcemanager.buildWorld(config)

    assert.are.same({garbage = {}}, world.gameState)
  end)
end)

describe("loading an entity with a nonexistent component", function ()
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

describe("loading an entity with an empty input", function ()
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

    local playerId = taggerMock.getId("player")
    local playerInput = world.gameState.input[playerId]
    assert.are.same("left", playerInput.walkLeft)
    assert.are.same("right", playerInput.walkRight)
    assert.are.same("up", playerInput.walkUp)
    assert.are.same("down", playerInput.walkDown)
  end)

  it("should create game state with default walk speed", function ()
    local world = resourcemanager.buildWorld(config)

    local playerId = taggerMock.getId("player")
    assert.are.same(400, world.gameState.impulseSpeed[playerId].walk)
  end)

  it("should create game state with default position", function ()
    local world = resourcemanager.buildWorld(config)

    local playerId = taggerMock.getId("player")
    local playerPosition = world.gameState.position[playerId]
    assert.are.same(400, playerPosition.x)
    assert.are.same(300, playerPosition.y)
  end)

  it("should create game state with default velocity", function ()
    local world = resourcemanager.buildWorld(config)

    local playerId = taggerMock.getId("player")
    local playerVelocity = world.gameState.velocity[playerId]
    assert.are.same(0, playerVelocity.x)
    assert.are.same(0, playerVelocity.y)
  end)
end)

describe("loading an entity with movement input and lacking keys", function ()
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

    local playerId = taggerMock.getId("player")
    local playerInput = world.gameState.input[playerId]
    assert.are.same("left2", playerInput.walkLeft)
    assert.are.same("right2", playerInput.walkRight)
    assert.is.falsy(playerInput.walkUp)
    assert.are.same("down2", playerInput.walkDown)
  end)
end)

describe("loading an entity with lacking movement input", function ()
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

    local playerId = taggerMock.getId("player")
    assert.is.falsy(world.gameState.input[playerId].walkRight)
  end)
end)

describe("loading an entity with movement input and keys", function ()
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

    local playerId = taggerMock.getId("player")
    local playerInput = world.gameState.input[playerId]
    assert.are.same("left2", playerInput.walkLeft)
    assert.are.same("right2", playerInput.walkRight)
    assert.are.same("up2", playerInput.walkUp)
    assert.are.same("down2", playerInput.walkDown)
  end)
end)

describe("loading an entity with only an empty speed list", function ()
  it("should create a game state", function ()
    local config = {
      entities = {
        player = {
          impulseSpeed = {}
        }
      }
    }

    local world = resourcemanager.buildWorld(config)

    assert.are.same({garbage = {}}, world.gameState)
  end)
end)

describe("loading an entity with impulse speeds", function ()
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

    local playerId = taggerMock.getId("player")
    local playerSpeed = world.gameState.impulseSpeed[playerId]
    assert.are.same(400, playerSpeed.walk)
    assert.are.same(200, playerSpeed.crouchWalk)
    assert.are.same(1200, playerSpeed.jump)
    assert.are.same(400, playerSpeed.climb)
  end)
end)

describe("loading config with nonempty menu", function ()
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

    local mainMenuId = taggerMock.getId("mainMenu")
    assert.are.same({"Start"}, world.gameState.menu[mainMenuId].options)
  end)

end)

describe("loading config with nonempty menu and other entities", function ()
  local config, world, mainMenuId, playerOneId, playerTwoId

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
    mainMenuId = taggerMock.getId("mainMenu")
    playerOneId = taggerMock.getId("playerOne")
    playerTwoId = taggerMock.getId("playerTwo")
  end)

  it("should load components with menu entity", function ()
    assert.are.same({"Start"}, world.gameState.menu[mainMenuId].options)
    assert.are.truthy(world.gameState.input[mainMenuId])
  end)

  it("should copy menu with default input", function ()
    local menuInput = world.gameState.input[mainMenuId]
    assert.are.same("up", menuInput.menuPrevious)
    assert.are.same("down", menuInput.menuNext)
  end)

  it("should not copy entities that have not the menu component", function ()
    assert.is.falsy(world.gameState.input[playerOneId])
    assert.is.falsy(world.gameState.input[playerTwoId])
    assert.is.falsy(world.gameState.position)
  end)
end)

describe("loading entities and an empty levels table", function ()
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

describe("loading a level with defined entity and position", function ()
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

    local playerId = taggerMock.getId("sonic")
    assert.is.truthy(world.gameState.input[playerId])
    assert.are.same(200, world.gameState.position[playerId].x)
    assert.are.same(300, world.gameState.position[playerId].y)
  end)
end)

describe("load two levels and the name of the first one", function ()
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

    local playerId = taggerMock.getId("sonic")
    assert.is.truthy(world.gameState.input[playerId])
    assert.are.same(200, world.gameState.position[playerId].x)
    assert.are.same(300, world.gameState.position[playerId].y)
  end)
end)

describe("loading a collector entity", function ()
  it("should copy the component", function ()
    local config = {
      entities = {
        player = {
          collector = true
        }
      }
    }

    local world = resourcemanager.buildWorld(config)

    local playerId = taggerMock.getId("player")
    assert.is.truthy(world.gameState.collector[playerId])
  end)
end)

describe("loading a collectable entity that is not in any level", function ()
  it("should not copy the component", function ()
    local config = {
      entities = {
        item = {
          collectable = true
        }
      }
    }

    local world = resourcemanager.buildWorld(config)

    assert.is.falsy(world.gameState.collectable)
  end)
end)

describe("loading collectable entities that are in a level", function ()
  local config = {
    entities = {
      bottle = {
        collectable = true
      }
    },
    levels = {
      garden = {
        bottle = {
          {0, 10},
          {10, 10},
          {20, 0}
        }
      }
    }
  }

  local world = resourcemanager.buildWorld(config)

  it("sould copy the collectable components with its name", function ()
    local collectable = world.gameState.collectable
    assert.are.same("bottle", collectable[1].name)
    assert.are.same("bottle", collectable[2].name)
    assert.are.same("bottle", collectable[3].name)
  end)
end)


describe("loading an entity that is both collector and collectable", function ()
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

describe("loading a collision box", function ()
  local config

  before_each(function ()
     config = {
      entities = {
        player = {
          collisionBox = {15, 35, 30, 70}
        }
      }
    }
  end)

  it("should copy the component", function ()
    local world = resourcemanager.buildWorld(config)

    local playerId = taggerMock.getId("player")
    local box = world.gameState.collisionBox[playerId]
    assert.are.same(15, box.origin.x)
    assert.are.same(35, box.origin.y)
    assert.are.same(30, box.width)
    assert.are.same(70, box.height)
  end)

  it("should create game state with default position", function ()
    local world = resourcemanager.buildWorld(config)

    local playerId = taggerMock.getId("player")
    local playerPosition = world.gameState.position[playerId]
    assert.are.same(400, playerPosition.x)
    assert.are.same(300, playerPosition.y)
  end)
end)

describe("loading a config with a spriteSheet and no sprites", function ()
  it("should not create a sprites table", function ()
    local config = {
      spriteSheet = "path/to/mySpriteSheet.png"
    }

    local world = resourcemanager.buildWorld(config)

    assert.are.falsy(world.sprites)
  end)
end)

describe("loading spriteSheet and empty sprites table", function ()
  it("should create a new image", function ()
    local spriteSheetPath = "path/to/mySpriteSheet.png"
    local config = {
      spriteSheet = spriteSheetPath,
      sprites = {}
    }

    resourcemanager.buildWorld(config)

    assert.stub(loveMock.graphics.newImage).was.called_with(spriteSheetPath)
  end)
end)

describe("loading spriteSheet and some sprites", function ()
  local spriteSheetPath, config, world

  before_each(function ()
    spriteSheetPath = "path/to/mySpriteSheet.png"
    config = {
      spriteSheet = spriteSheetPath,
      sprites = {
        {1, 1, 32, 32, 16, 32},
        {33, 1, 32, 32, 0, 0},
        {1, 33, 32, 32, 16, 16}
      }
    }
    world = resourcemanager.buildWorld(config)
  end)

  it("should create the same number of quads as sprites", function ()
    assert.stub(loveMock.graphics.newQuad).was.called(#config.sprites)
  end)

  it("should create the sprites with their defined origins", function ()
    assert.are.same({x = 16, y = 32}, world.sprites[1].origin)
    assert.are.same({x = 0, y = 0}, world.sprites[2].origin)
    assert.are.same({x = 16, y = 16}, world.sprites[3].origin)
  end)
end)
