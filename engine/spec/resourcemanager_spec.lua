local resourcemanager, loveMock, entityTagger, command, _

before_each(function ()
  resourcemanager = require "engine.resourcemanager"
  entityTagger = require "engine.tagger"
  command = require "engine.command"
  local match = require "luassert.match"
  _ = match._

  local love = {graphics = {}}
  function love.graphics.getWidth()
    return 800
  end
  function love.graphics.getHeight()
    return 600
  end
  function love.graphics.getDimensions()
    return love.graphics.getWidth(), love.graphics.getHeight()
  end
  function love.graphics.newImage()
    return {
      getDimensions = function () return nil end,
      setWrap = function () end
    }
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

describe("setting inputs to an entity that is not in config", function ()
  local world, walkLeft

  before_each(function ()
    world = resourcemanager.buildWorld{}

    walkLeft = command.new{input = "left"}
    resourcemanager.setInputs(world, "player", {walkLeft = walkLeft})
  end)

  it("should not create a controllable component", function ()
    assert.is.falsy(world.gameState.components.controllable)
  end)

  it("should create a commands table", function ()
    assert.are.same({player = "walkLeft"}, world.hid.commands[walkLeft])
  end)
end)

describe("loading a controllable entity", function ()
  local config, world, walkLeft, walkRight, walkUp, walkDown, playerId

  before_each(function ()
    config = {
      entities = {
        player = {
          flags = {"controllable"}
        }
      }
    }

    world = resourcemanager.buildWorld(config)
    
    walkLeft = command.new{input = "left"}
    walkRight = command.new{input = "right"}
    walkUp = command.new{input = "up"}
    walkDown = command.new{input = "down"}
    resourcemanager.setInputs(world, "player", {
      walkLeft = walkLeft,
      walkRight = walkRight,
      walkUp = walkUp,
      walkDown = walkDown
    })
    playerId = entityTagger.getId("player")
  end)

  it("should create a component for the entity", function ()
    local playerActions = world.gameState.components.controllable[playerId]
    assert.are.same(false, playerActions.walkLeft)
    assert.are.same(false, playerActions.walkRight)
    assert.are.same(false, playerActions.walkUp)
    assert.are.same(false, playerActions.walkDown)
  end)

  it("should map the defined commands with the entity", function ()
    assert.are.same({player = "walkLeft"}, world.hid.commands[walkLeft])
    assert.are.same({player = "walkRight"}, world.hid.commands[walkRight])
    assert.are.same({player = "walkUp"}, world.hid.commands[walkUp])
    assert.are.same({player = "walkDown"}, world.hid.commands[walkDown])
  end)
end)

describe("loading two entities that share the same input", function ()
  it("should map the defined commands with the entities", function ()
    local config = {
      entities = {
        ryu = {
          flags = {"controllable"}
        },
        ken = {
          flags = {"controllable"}
        }
      }
    }
    local world = resourcemanager.buildWorld(config)
    
    local walkLeft = command.new{input = "left"}
    local walkRight = command.new{input = "right"}
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
          flags = {"controllable"}
        },
        ken = {
          flags = {"controllable"}
        }
      }
    }
    local world = resourcemanager.buildWorld(config)
    
    local walkLeftRyu = command.new{input = "left"}
    local walkLeftKen = command.new{input = "left"}
    local walkRightRyu = command.new{input = "right"}
    local walkRightKen = command.new{input = "right"}
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

describe("loading an entity with movement inputs and lacking keys", function ()
  it("should copy the defined keys and ignore the rest", function ()
    local config = {
      keys = {
        left2 = "j",
        right2 = "l",
        down2 = "k"
      },
      entities = {
        player = {
          flags = {"controllable"}
        }
      }
    }
    local world = resourcemanager.buildWorld(config)

    resourcemanager.setInputs(world, "player", {
      walkLeft = command.new{input = "left2"},
      walkRight = command.new{input = "right2"},
      walkUp = command.new{input = "up2"},
      walkDown = command.new{input = "down2"}
    })

    local playerId = entityTagger.getId("player")
    local playerActions = world.gameState.components.controllable[playerId]
    assert.are.same(false, playerActions.walkLeft)
    assert.are.same(false, playerActions.walkRight)
    assert.is.falsy(playerActions.walkUp)
    assert.are.same(false, playerActions.walkDown)
  end)
end)

describe("loading a controllable entity and keys", function ()
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
          flags = {"controllable"}
        }
      }
    }
    local world = resourcemanager.buildWorld(config)

    resourcemanager.setInputs(world, "player", {
      walkLeft = command.new{input = "left2"},
      walkRight = command.new{input = "right2"},
      walkUp = command.new{input = "up2"},
      walkDown = command.new{input = "down2"}
    })

    local playerId = entityTagger.getId("player")
    local playerActions = world.gameState.components.controllable[playerId]
    assert.are.same(false, playerActions.walkLeft)
    assert.are.same(false, playerActions.walkRight)
    assert.are.same(false, playerActions.walkUp)
    assert.are.same(false, playerActions.walkDown)
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
      walkLeft =  command.new{input = "left"},
      walkRight = command.new{input = "right"},
      walkUp = command.new{input = "up"},
      walkDown = command.new{input = "down"}
    })
    resourcemanager.setInputs(world, "mainMenu", {
      menuPrevious = command.new{input = "up"},
      menuNext = command.new{input = "down"},
      menuSelect = command.new{input = "start"}
    })
    mainMenuId = entityTagger.getId("mainMenu")
    playerOneId = entityTagger.getId("playerOne")
    playerTwoId = entityTagger.getId("playerTwo")
  end)

  it("should copy menu with its actions", function ()
    local menuActions = world.gameState.components.controllable[mainMenuId]
    assert.are.same(false, menuActions.menuPrevious)
    assert.are.same(false, menuActions.menuNext)
    assert.are.same(false, menuActions.menuSelect)
  end)
end)
