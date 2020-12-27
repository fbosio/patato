local resourcemanager, loveMock, entityTagger

before_each(function ()
  resourcemanager = require "engine.resourcemanager"
  entityTagger = require "engine.tagger"

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

  resourcemanager.load(loveMock, entityTagger)
end)

after_each(function ()
  package.loaded["engine.resourcemanager"] = nil
  package.loaded["engine.tagger"] = nil
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
    assert.are.same("a", emptyWorld.hid.keys.left)
    assert.are.same("d", emptyWorld.hid.keys.right)
    assert.are.same("w", emptyWorld.hid.keys.up)
    assert.are.same("s", emptyWorld.hid.keys.down)
  end)

  it("should create a garbage component table", function ()
    assert.are.truthy(emptyWorld.gameState.components.garbage)
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

    assert.are.same("a", world.hid.keys.left)
    assert.are.same("d", world.hid.keys.right)
    assert.are.same("w", world.hid.keys.up)
    assert.are.same("s", world.hid.keys.down)
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

    assert.are.same("j", world.hid.keys.left)
    assert.are.same("l", world.hid.keys.right)
    assert.are.same("i", world.hid.keys.up)
    assert.are.same("k", world.hid.keys.down)
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

    assert.are.same("j", world.hid.keys.left)
    assert.are.same("d", world.hid.keys.right)
    assert.are.same("w", world.hid.keys.up)
    assert.are.same("k", world.hid.keys.down)
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

    assert.are.same("j", world.hid.keys["super cool action 1"])
    assert.are.same("k", world.hid.keys["super cool action 2"])
  end)
end)

describe("loading an empty entities list", function ()
  it("should create a game state with a garbage table only", function ()
    local config = {
      entities = {}
    }

    local world = resourcemanager.buildWorld(config)

    assert.are.same({garbage = {}}, world.gameState.components)
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

    assert.are.same({garbage = {}}, world.gameState.components)
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

    local playerId = entityTagger.getId("player")
    local playerInput = world.gameState.components.input[playerId]
    assert.are.same("left", playerInput.walkLeft)
    assert.are.same("right", playerInput.walkRight)
    assert.are.same("up", playerInput.walkUp)
    assert.are.same("down", playerInput.walkDown)
  end)

  it("should create game state with default walk speed", function ()
    local world = resourcemanager.buildWorld(config)

    local playerId = entityTagger.getId("player")
    assert.are.same(400,
                    world.gameState.components.impulseSpeed[playerId].walk)
  end)

  it("should create game state with default position", function ()
    local world = resourcemanager.buildWorld(config)

    local playerId = entityTagger.getId("player")
    local playerPosition = world.gameState.components.position[playerId]
    assert.are.same(400, playerPosition.x)
    assert.are.same(300, playerPosition.y)
  end)

  it("should create game state with default velocity", function ()
    local world = resourcemanager.buildWorld(config)

    local playerId = entityTagger.getId("player")
    local playerVelocity = world.gameState.components.velocity[playerId]
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

    local playerId = entityTagger.getId("player")
    local playerInput = world.gameState.components.input[playerId]
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

    local playerId = entityTagger.getId("player")
    assert.is.falsy(world.gameState.components.input[playerId].walkRight)
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

    local playerId = entityTagger.getId("player")
    local playerInput = world.gameState.components.input[playerId]
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

    assert.are.same({garbage = {}}, world.gameState.components)
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

    local playerId = entityTagger.getId("player")
    local playerSpeed = world.gameState.components.impulseSpeed[playerId]
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

    local mainMenuId = entityTagger.getId("mainMenu")
    assert.are.same({"Start"},
                    world.gameState.components.menu[mainMenuId].options)
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
    mainMenuId = entityTagger.getId("mainMenu")
    playerOneId = entityTagger.getId("playerOne")
    playerTwoId = entityTagger.getId("playerTwo")
  end)

  it("should load components with menu entity", function ()
    assert.are.same({"Start"},
                    world.gameState.components.menu[mainMenuId].options)
    assert.are.truthy(world.gameState.components.input[mainMenuId])
  end)

  it("should copy menu with default input", function ()
    local menuInput = world.gameState.components.input[mainMenuId]
    assert.are.same("up", menuInput.menuPrevious)
    assert.are.same("down", menuInput.menuNext)
  end)

  it("should not copy entities that have not the menu component", function ()
    assert.is.falsy(world.gameState.components.input[playerOneId])
    assert.is.falsy(world.gameState.components.input[playerTwoId])
    assert.is.falsy(world.gameState.components.position)
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

    assert.is.falsy(world.gameState.components.input)
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

    local playerId = entityTagger.getId("sonic")
    assert.is.truthy(world.gameState.components.input[playerId])
    assert.are.same(200, world.gameState.components.position[playerId].x)
    assert.are.same(300, world.gameState.components.position[playerId].y)
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

    local playerId = entityTagger.getId("sonic")
    assert.is.truthy(world.gameState.components.input[playerId])
    assert.are.same(200, world.gameState.components.position[playerId].x)
    assert.are.same(300, world.gameState.components.position[playerId].y)
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

    local playerId = entityTagger.getId("player")
    assert.is.truthy(world.gameState.components.collector[playerId])
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

    assert.is.falsy(world.gameState.components.collectable)
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
    local collectable = world.gameState.components.collectable
    assert.are.same("bottle", collectable[1].name)
    assert.are.same("bottle", collectable[2].name)
    assert.are.same("bottle", collectable[3].name)
  end)

  it("should copy the positions of the collectable components", function ()
    local position = world.gameState.components.position
    assert.are.same(0, position[1].x)
    assert.are.same(10, position[1].y)
    assert.are.same(10, position[2].x)
    assert.are.same(10, position[2].y)
    assert.are.same(20, position[3].x)
    assert.are.same(0, position[3].y)
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

    local playerId = entityTagger.getId("player")
    local box = world.gameState.components.collisionBox[playerId]
    assert.are.same(15, box.origin.x)
    assert.are.same(35, box.origin.y)
    assert.are.same(30, box.width)
    assert.are.same(70, box.height)
  end)

  it("should create game state with default position", function ()
    local world = resourcemanager.buildWorld(config)

    local playerId = entityTagger.getId("player")
    local playerPosition = world.gameState.components.position[playerId]
    assert.are.same(400, playerPosition.x)
    assert.are.same(300, playerPosition.y)
  end)
end)

describe("loading a config with a spriteSheet and no sprites", function ()
  it("should create an empty resources table", function ()
    local config = {
      spriteSheet = "path/to/mySpriteSheet.png"
    }

    local world = resourcemanager.buildWorld(config)

    assert.are.same({}, world.resources)
  end)
end)

describe("loading spriteSheet and empty sprites table", function ()
  local spriteSheetPath, config, world

  before_each(function ()
    spriteSheetPath = "path/to/mySpriteSheet.png"
    config = {
      spriteSheet = spriteSheetPath,
      sprites = {}
    }

    world = resourcemanager.buildWorld(config)
  end)

  it("should create a new image", function ()
    assert.stub(loveMock.graphics.newImage).was.called_with(spriteSheetPath)
  end)

  it("should load a default sprite scale", function ()
    assert.are.same(1, world.resources.spriteScale)
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
    assert.are.same({x = 16, y = 32}, world.resources.sprites[1].origin)
    assert.are.same({x = 0, y = 0}, world.resources.sprites[2].origin)
    assert.are.same({x = 16, y = 16}, world.resources.sprites[3].origin)
  end)
end)

describe("loading sprites and an entity with animations", function ()
  local config, world

  before_each(function ()
    config = {
      spriteSheet = "path/to/mySpriteSheet.png",
      sprites = {
        {1, 1, 32, 32, 16, 32},
        {33, 1, 32, 32, 0, 0},
        {1, 33, 32, 32, 16, 16}
      },
      entities = {
        player = {
          animations = {
            standing = {1, 1},
            walking = {2, 0.5, 3, 0.5, 4, 0.5, 3, 0.5, true}
          }
        }
      }
    }

    world = resourcemanager.buildWorld(config)
  end)

  it ("should create an animations table", function ()
    local animations = world.resources.animations
    local standingAnimation = animations.player.standing
    assert.are.same({1}, standingAnimation.frames)
    assert.are.same({1}, standingAnimation.durations)
    assert.is.falsy(standingAnimation.looping)

    local walkingAnimation = animations.player.walking
    assert.are.same({2, 3, 4, 3}, walkingAnimation.frames)
    assert.are.same({0.5, 0.5, 0.5, 0.5}, walkingAnimation.durations)
    assert.is.truthy(walkingAnimation.looping)
  end)

  it("should create an animation component", function ()
    local playerId = entityTagger.getId("player")
    local playerAnimation = world.gameState.components.animation[playerId]
    assert.are.same(1, playerAnimation.frame)
    assert.are.same(0, playerAnimation.time)
    assert.are.falsy(playerAnimation.ended)
  end)
end)

describe("loading entities with animations with the same name", function ()
  it("should load the animations separately", function ()
    local config = {
      spriteSheet = "path/to/mySpriteSheet.png",
      sprites = {
        {1, 1, 32, 32, 16, 32},
        {33, 1, 32, 32, 0, 0},
      },
      entities = {
        coin = {
          animations = {
            idle = {1, 1}
          }
        },
        bottle = {
          animations = {
            idle = {2, 1}
          }
        }
      }
    }

    local world = resourcemanager.buildWorld(config)

    assert.is.truthy(world.resources.animations.coin.idle)
    assert.is.truthy(world.resources.animations.bottle.idle)
  end)
end)

describe("loading config with sprite scale", function ()
  it("should store it in resources table", function ()
    local config = {
      spriteSheet = "path/to/mySpriteSheet.png",
      spriteScale = 0.5,
      sprites = {}
    }

    local world = resourcemanager.buildWorld(config)

    assert.are.same(0.5, world.resources.spriteScale)
  end)
end)

describe("loading a solid entity", function ()
  it("should copy the component", function ()
    local config = {
      entities = {
        player = {
          solid = true
        }
      }
    }

    local world = resourcemanager.buildWorld(config)

    local playerId = entityTagger.getId("player")
    assert.is.truthy(world.gameState.components.solid[playerId])
  end)
end)

describe("loading a collideable entity that is not in any level", function ()
  it("should not copy the component", function ()
    local config = {
      entities = {
        surface = {
          collideable = true
        }
      }
    }

    local world = resourcemanager.buildWorld(config)

    assert.is.falsy(world.gameState.components.collideable)
  end)
end)

describe("loading collideable entities that are in a level", function ()
  local config = {
    entities = {
      surfaces = {
        collideable = true
      }
    },
    levels = {
      garden = {
        surfaces = {
          {400, 50, 700, 200},
          {400, 400, 700, 550},
        }
      }
    }
  }

  local world = resourcemanager.buildWorld(config)

  it("sould copy the collideable components with its name", function ()
    local collideable = world.gameState.components.collideable
    assert.are.same("surfaces", collideable[1].name)
    assert.are.same("surfaces", collideable[2].name)
  end)
end)

describe("loading an entity that is both collideable and solid", function ()
  it("should throw an error", function ()
    local config = {
      entities = {
        absurdSpecimen = {
          collideable = true,
          solid = true
        }
      }
    }

    assert.has_error(function () resourcemanager.buildWorld(config) end)
  end)
end)