local resourcemanager, loveMock, entityTagger, command

before_each(function ()
  resourcemanager = require "engine.resourcemanager"
  entityTagger = require "engine.tagger"
  command = require "engine.command"

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
  package.loaded["engine.command"] = nil
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

  it("should create an empty joystick table", function ()
    assert.are.same({}, emptyWorld.hid.joystick)
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
  it("should load a world with default movement keys", function ()
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

describe("setting input to an entity that is not in config", function ()
  local world, walkLeft

  before_each(function ()
    world = resourcemanager.buildWorld{}

    walkLeft = command.new{key = "left"}
    resourcemanager.setInputs(world, "player", {walkLeft = walkLeft})
  end)

  it("should not create an input component", function ()
    assert.is.falsy(world.gameState.components.input)
  end)

  it("should create a commands table", function ()
    assert.are.same({player = "walkLeft"}, world.hid.commands[walkLeft])
  end)
end)

describe("loading an entity with an input", function ()
  local config, world, walkLeft, walkRight, walkUp, walkDown, playerId

  before_each(function ()
    config = {
      entities = {
        player = {
          input = true
        }
      }
    }
    world = resourcemanager.buildWorld(config)
    
    walkLeft = command.new{key = "left"}
    walkRight = command.new{key = "right"}
    walkUp = command.new{key = "up"}
    walkDown = command.new{key = "down"}
    resourcemanager.setInputs(world, "player", {
      walkLeft = walkLeft,
      walkRight = walkRight,
      walkUp = walkUp,
      walkDown = walkDown
    })
    playerId = entityTagger.getId("player")
  end)

  it("should create a component for the entity", function ()    
    local playerInput = world.gameState.components.input[playerId]
    assert.are.same(false, playerInput.walkLeft)
    assert.are.same(false, playerInput.walkRight)
    assert.are.same(false, playerInput.walkUp)
    assert.are.same(false, playerInput.walkDown)
  end)

  it("should map the defined commands with the entity", function ()
    assert.are.same({player = "walkLeft"}, world.hid.commands[walkLeft])
    assert.are.same({player = "walkRight"}, world.hid.commands[walkRight])
    assert.are.same({player = "walkUp"}, world.hid.commands[walkUp])
    assert.are.same({player = "walkDown"}, world.hid.commands[walkDown])
  end)

  it("should set default components to the entity", function ()
    assert.are.same({x = 400, y = 300},
                    world.gameState.components.position[playerId])
    assert.are.same({x = 0, y = 0},
                    world.gameState.components.velocity[playerId])
    assert.are.same({walk = 400, jump = 1500},
                    world.gameState.components.impulseSpeed[playerId])
  end)
end)

describe("loading two entities that share the same input", function ()
  it("should map the defined commands with the entities", function ()
    local config = {
      entities = {
        ryu = {
          input = true
        },
        ken = {
          input = true
        }
      }
    }
    local world = resourcemanager.buildWorld(config)
    
    local walkLeft = command.new{key = "left"}
    local walkRight = command.new{key = "right"}
    resourcemanager.setInputs(world, "ryu", {
      walkLeft = walkLeft,
      walkRight = walkRight
    })
    resourcemanager.setInputs(world, "ken", {
      walkLeft = walkLeft,
      walkRight = walkRight
    })

    assert.are.same({ryu = "walkLeft", ken = "walkLeft"},
                     world.hid.commands[walkLeft])
    assert.are.same({ryu = "walkRight", ken = "walkRight"},
                     world.hid.commands[walkRight])
  end)
end)

describe("setting two equal commands with different references", function ()
  it("should map all the actions to the first command", function ()
    local config = {
      entities = {
        ryu = {
          input = true
        },
        ken = {
          input = true
        }
      }
    }
    local world = resourcemanager.buildWorld(config)
    
    local walkLeftRyu = command.new{key = "left"}
    local walkLeftKen = command.new{key = "left"}
    local walkRightRyu = command.new{key = "right"}
    local walkRightKen = command.new{key = "right"}
    resourcemanager.setInputs(world, "ryu", {
      walkLeft = walkLeftRyu,
      walkRight = walkRightRyu
    })
    resourcemanager.setInputs(world, "ken", {
      walkLeft = walkLeftKen,
      walkRight = walkRightKen
    })

    assert.are.same({ryu = "walkLeft", ken = "walkLeft"},
                     world.hid.commands[walkLeftRyu])
    assert.are.same({ryu = "walkRight", ken = "walkRight"},
                     world.hid.commands[walkRightRyu])
    assert.is.falsy(world.hid.commands[walkLeftKen])
    assert.is.falsy(world.hid.commands[walkRightKen])
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
          input = true
        }
      }
    }
    local world = resourcemanager.buildWorld(config)

    resourcemanager.setInputs(world, "player", {
      walkLeft = command.new{key = "left2"},
      walkRight = command.new{key = "right2"},
      walkUp = command.new{key = "up2"},
      walkDown = command.new{key = "down2"}
    })

    local playerId = entityTagger.getId("player")
    local playerInput = world.gameState.components.input[playerId]
    assert.are.same(false, playerInput.walkLeft)
    assert.are.same(false, playerInput.walkRight)
    assert.is.falsy(playerInput.walkUp)
    assert.are.same(false, playerInput.walkDown)
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
          input = true
        }
      }
    }
    local world = resourcemanager.buildWorld(config)

    resourcemanager.setInputs(world, "player", {
      walkLeft = command.new{key = "left2"},
      walkRight = command.new{key = "right2"},
      walkUp = command.new{key = "up2"},
      walkDown = command.new{key = "down2"}
    })

    local playerId = entityTagger.getId("player")
    local playerInput = world.gameState.components.input[playerId]
    assert.are.same(false, playerInput.walkLeft)
    assert.are.same(false, playerInput.walkRight)
    assert.are.same(false, playerInput.walkUp)
    assert.are.same(false, playerInput.walkDown)
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

describe("bulding world with nonempty menu and other entities", function ()
  local config, world, mainMenuId, playerOneId, playerTwoId

  before_each(function ()
    config = {
      entities = {
        mainMenu = {
          menu = {
            options = {"Start"}
          }
        }
      }
    }
    world = resourcemanager.buildWorld(config)
    resourcemanager.setInputs(world, "playerOne", {
      walkLeft =  command.new{key = "left"},
      walkRight = command.new{key = "right"},
      walkUp = command.new{key = "up"},
      walkDown = command.new{key = "down"}
    })
    resourcemanager.setInputs(world, "mainMenu", {
      menuPrevious = command.new{key = "up"},
      menuNext = command.new{key = "down"},
      menuSelect = command.new{key = "start"}
    })
    mainMenuId = entityTagger.getId("mainMenu")
    playerOneId = entityTagger.getId("playerOne")
    playerTwoId = entityTagger.getId("playerTwo")
  end)

  it("should load components with menu entity", function ()
    assert.are.same({"Start"},
                    world.gameState.components.menu[mainMenuId].options)
    assert.are.truthy(world.gameState.components.input[mainMenuId])
  end)

  it("should copy menu with its input", function ()
    local menuInput = world.gameState.components.input[mainMenuId]
    assert.are.same(false, menuInput.menuPrevious)
    assert.are.same(false, menuInput.menuNext)
    assert.are.same(false, menuInput.menuSelect)
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
          input = true
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
          input = true
        }
      },
      levels = {
        ["green hill zone"] = {
          sonic = {200, 300}
        }
      }
    }

    local world = resourcemanager.buildWorld(config)
    resourcemanager.setInputs(world, "sonic", {
      walkLeft = command.new{key = "left"},
      walkRight = command.new{key = "right"}
    })

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
          input = true
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
    resourcemanager.setInputs(world, "sonic", {
      walkLeft = command.new{key = "left"},
      walkRight = command.new{key = "right"}
    })

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
  local config
  before_each(function ()
    config = {
      entities = {
        absurdSpecimen = {
          collector = true,
          collectable = true
        }
      }
    }
  end)

  describe("without levels defined", function ()
    it("should throw an error", function ()
      assert.has_error(function () resourcemanager.buildWorld(config) end)
    end)
  end)

  describe("with a level defined", function ()
    it("should throw an error", function ()
      config.levels = {
        absurdSpecimen = {
          {0, 10},
          {10, 10},
          {20, 0}
        }
      }
      assert.has_error(function () resourcemanager.buildWorld(config) end)
    end)
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
          collideable = "rectangle"
        }
      }
    }

    local world = resourcemanager.buildWorld(config)

    assert.is.falsy(world.gameState.components.collideable)
  end)
end)

describe("loading surface entities that are in a level", function ()
  local config, world

  before_each(function ()
    config = {
      entities = {
        surfaces = {
          collideable = "rectangle"
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
  
    world = resourcemanager.buildWorld(config)
  end)

  it("should copy the collideable components with its name", function ()
    local collideable = world.gameState.components.collideable
    assert.are.same("surfaces", collideable[1].name)
    assert.are.same("surfaces", collideable[2].name)
  end)

  it("should create collision boxes for each entity", function ()
    assert.are.same({
      {origin = {x = 150, y = 75}, width = 300, height = 150},
      {origin = {x = 150, y = 75}, width = 300, height = 150},
    }, world.gameState.components.collisionBox)
  end)
end)

describe("loading cloud entities that are in a level", function ()
  it("should create collision lines for each entity", function ()
    local config = {
      entities = {
        clouds = {
          collideable = "rectangle"
        }
      },
      levels = {
        garden = {
          clouds = {
            {400, 50, 700},
            {400, 400, 700},
          }
        }
      }
    }
  
    local world = resourcemanager.buildWorld(config)
    
    local collisionBox = world.gameState.components.collisionBox
    assert.are.same({
      {origin = {x = 150, y = 0}, width = 300, height = 0},
      {origin = {x = 150, y = 0}, width = 300, height = 0},
    }, collisionBox)
  end)
end)

describe("loading slope entities that are in a level", function ()
  local config, world

  before_each(function ()
    config = {
      entities = {
        slopes = {
          collideable = "triangle"
        }
      },
      levels = {
        garden = {
          slopes = {
            {10, 10, 0, 0},
            {20, 10, 30, 0},
            {10, 20, 0, 30},
            {20, 20, 30, 30},
          }
        }
      }
    }
  
    world = resourcemanager.buildWorld(config)
  end)

  it("should create collision boxes for each entity", function ()
    assert.are.same({
      {origin = {x = 5, y = 5}, width = 10, height = 10},
      {origin = {x = 5, y = 5}, width = 10, height = 10},
      {origin = {x = 5, y = 5}, width = 10, height = 10},
      {origin = {x = 5, y = 5}, width = 10, height = 10},
    }, world.gameState.components.collisionBox)
  end)

  it("should create a collideable with slope attributes", function ()
    local collideable = world.gameState.components.collideable
    assert.is.truthy(collideable[1].normalPointingUp)
    assert.is.falsy(collideable[1].rising)
    assert.is.truthy(collideable[2].normalPointingUp)
    assert.is.truthy(collideable[2].rising)
    assert.is.falsy(collideable[3].normalPointingUp)
    assert.is.truthy(collideable[3].rising)
    assert.is.falsy(collideable[4].normalPointingUp)
    assert.is.falsy(collideable[4].rising)
  end)
end)

describe("loading an entity that has a wrong collideable type", function ()
  it("should throw an error", function ()
    local config = {
      entities = {
        surfaceWithTypo = {
          collideable = "rectanlgbe"
        }
      },
      levels = {
        garden = {
          surfaceWithTypo = {
            {400, 50, 700},
            {400, 400, 700},
          }
        }
      }
    }

    assert.has_error(function () resourcemanager.buildWorld(config) end)
  end)
end)

describe("loading an entity that is both collideable and solid", function ()
  local config
  before_each(function ()
    config = {
      entities = {
        absurdSpecimen = {
          collideable = "rectangle",
          solid = true
        }
      }
    }
  end)

  describe("without levels defined", function ()
    it("should throw an error", function ()
      assert.has_error(function () resourcemanager.buildWorld(config) end)
    end)
  end)

  describe("with a level defined", function ()
    it("should throw an error", function ()
      config.levels = {
        absurdSpecimen = {
          {400, 50, 700, 200},
          {400, 400, 700, 550},
        }
      }
      assert.has_error(function () resourcemanager.buildWorld(config) end)
    end)
  end)
end)

describe("loading a gravitational entity", function ()
  it("should copy the component", function ()
    local config = {
      entities = {
        anvil = {
          gravitational = true
        }
      }
    }

    local world = resourcemanager.buildWorld(config)

    local anvilId = entityTagger.getId("anvil")
    assert.is.truthy(world.gameState.components.gravitational[anvilId])
  end)
end)

describe("loading a climber entity", function ()
  it("should copy the component", function ()
    local config = {
      entities = {
        player = {
          climber = true
        }
      }
    }

    local world = resourcemanager.buildWorld(config)

    local playerId = entityTagger.getId("player")
    assert.is.truthy(world.gameState.components.climber[playerId])
  end)
end)

describe("loading a trellis entity that is not in any level", function ()
  it("should not copy the component", function ()
    local config = {
      entities = {
        trellis = {
          trellis = true
        }
      }
    }

    local world = resourcemanager.buildWorld(config)

    assert.is.falsy(world.gameState.components.trellis)
  end)
end)

describe("loading trellis entities that are in a level", function ()
  local config, world

  before_each(function ()
    config = {
      entities = {
        trellises = {
          trellis = true
        }
      },
      levels = {
        garden = {
          trellises = {
            {400, 50, 700, 200},
            {400, 400, 700, 550},
          }
        }
      }
    }
  
    world = resourcemanager.buildWorld(config)
  end)

  it("should copy the trellis components with its name", function ()
    local trellis = world.gameState.components.trellis
    assert.are.same("trellises", trellis[1].name)
    assert.are.same("trellises", trellis[2].name)
  end)

  it("should create collision boxes for each entity", function ()
    assert.are.same({
      {origin = {x = 150, y = 75}, width = 300, height = 150},
      {origin = {x = 150, y = 75}, width = 300, height = 150},
    }, world.gameState.components.collisionBox)
  end)
end)

describe("loading an entity that is both climber and trellis", function ()
  local config
  before_each(function ()
    config = {
      entities = {
        absurdSpecimen = {
          climber = true,
          trellis = true
        }
      }
    }
  end)

  describe("without levels defined", function ()
    it("should throw an error", function ()
      assert.has_error(function () resourcemanager.buildWorld(config) end)
    end)
  end)

  describe("with a level defined", function ()
    it("should throw an error", function ()
      config.levels = {
        absurdSpecimen = {
          {400, 50, 700, 200},
          {400, 400, 700, 550},
        }
      }
      assert.has_error(function () resourcemanager.buildWorld(config) end)
    end)
  end)
end)
