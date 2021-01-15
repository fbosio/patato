local gamestate, entityTagger, loveMock

before_each(function ()
  gamestate = require "engine.systems.loaders.gamestate.init"
  entityTagger = require "engine.tagger"
  local love = {graphics = {}}
  function love.graphics.getDimensions()
    return 800, 600
  end
  loveMock = mock(love)
end)

after_each(function ()
  package.loaded["engine.systems.loaders.gamestate.init"] = nil
  package.loaded["engine.tagger"] = nil
end)

describe("loading an empty config", function ()
  it("should create a garbage component table", function ()
    local emptyConfig = {}
    local loadedGameState = gamestate.load(loveMock, entityTagger, {},
                                           emptyConfig)

    assert.are.truthy(loadedGameState.components.garbage)
  end)
end)

describe("loading an empty entities list", function ()
  it("should create a game state with a garbage table only", function ()
    local config = {
      entities = {}
    }

    local loadedGameState = gamestate.load(loveMock, entityTagger, {}, config)

    assert.are.truthy(loadedGameState.components.garbage)
  end)
end)

describe("loading an entity without components", function ()
  it("should create a game state with a garbage table only", function ()
    local config = {
      entities = {
        player = {}
      }
    }

    local loadedGameState = gamestate.load(loveMock, entityTagger, {}, config)

    assert.are.truthy(loadedGameState.components.garbage)
  end)
end)

describe("loading a nonmenu controllable entity", function ()
  local config, loadedGameState, playerId

  before_each(function ()
    config = {
      entities = {
        player = {
          flags = {"controllable"}
        }
      }
    }

    loadedGameState = gamestate.load(loveMock, entityTagger, {}, config)
    playerId = entityTagger.getId("player")
  end)

  it("should create a component for the entity", function ()
    assert.is.truthy(loadedGameState.components.controllable[playerId])
  end)

  it("should set default components to the entity", function ()
    assert.are.same({x = 400, y = 300},
                    loadedGameState.components.position[playerId])
    assert.are.same({x = 0, y = 0},
                    loadedGameState.components.velocity[playerId])
    assert.are.same({walk = 400},
                    loadedGameState.components.impulseSpeed[playerId])
  end)
end)

describe("loading a controllable entity with a walk speed defined", function ()
  it("should not overwrite the speed", function ()
    local config = {
      entities = {
        player = {
          flags = {"controllable"},
          impulseSpeed = {walk = 800}
        }
      }
    }
    local loadedGameState = gamestate.load(loveMock, entityTagger, {}, config)
    local playerId = entityTagger.getId("player")
    assert.are.same({walk = 800},
                    loadedGameState.components.impulseSpeed[playerId])
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

    local loadedGameState = gamestate.load(loveMock, entityTagger, {}, config)

    assert.are.same({garbage = {}}, loadedGameState.components)
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

    local loadedGameState = gamestate.load(loveMock, entityTagger, {}, config)

    local playerId = entityTagger.getId("player")
    local playerSpeed = loadedGameState.components.impulseSpeed[playerId]
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

    local loadedGameState = gamestate.load(loveMock, entityTagger, {}, config)

    local mainMenuId = entityTagger.getId("mainMenu")
    assert.are.same({"Start"},
                    loadedGameState.components.menu[mainMenuId].options)
  end)
end)

describe("bulding world with nonempty menu and other entities", function ()
  local config, loadedGameState, mainMenuId, playerOneId, playerTwoId

  before_each(function ()
    config = {
      entities = {
        playerOne = {
          flags = {"controllable"}
        },
        playerTwo = {
          flags = {"controllable"}
        },
        mainMenu = {
          flags = {"controllable"},
          menu = {
            options = {"Start"}
          }
        }
      }
    }
    loadedGameState = gamestate.load(loveMock, entityTagger, {}, config)
    mainMenuId = entityTagger.getId("mainMenu")
    playerOneId = entityTagger.getId("playerOne")
    playerTwoId = entityTagger.getId("playerTwo")
  end)

  it("should load components with menu entity", function ()
    assert.are.same({"Start"},
                    loadedGameState.components.menu[mainMenuId].options)
    assert.are.truthy(loadedGameState.components.controllable[mainMenuId])
  end)

  it("should not copy entities that have not the menu component", function ()
    assert.is.falsy(loadedGameState.components.controllable[playerOneId])
    assert.is.falsy(loadedGameState.components.controllable[playerTwoId])
    assert.is.falsy(loadedGameState.components.position)
  end)
end)

describe("loading entities and an empty levels table", function ()
  it("should not copy the entities", function ()
    local config = {
      entities = {
        player = {
          flags = {"controllable"}
        }
      },
      levels = {}
    }

    local loadedGameState = gamestate.load(loveMock, entityTagger, {}, config)

    assert.is.falsy(loadedGameState.components.controllable)
  end)
end)

describe("loading a level with defined entity and position", function ()
  it("should copy that entity with that position", function ()
    local config = {
      entities = {
        sonic = {
          flags = {"controllable"}
        }
      },
      levels = {
        ["green hill zone"] = {
          sonic = {200, 300}
        }
      }
    }

    local loadedGameState = gamestate.load(loveMock, entityTagger, {}, config)

    local playerId = entityTagger.getId("sonic")
    assert.is.truthy(loadedGameState.components.controllable[playerId])
    assert.are.same(200, loadedGameState.components.position[playerId].x)
    assert.are.same(300, loadedGameState.components.position[playerId].y)
  end)
end)

describe("load two levels and the name of the first one", function ()
  it("should start the game in the first level", function ()
    local config = {
      entities = {
        sonic = {
          flags = {"controllable"}
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

    local loadedGameState = gamestate.load(loveMock, entityTagger, {}, config)

    local playerId = entityTagger.getId("sonic")
    assert.is.truthy(loadedGameState.components.controllable[playerId])
    assert.are.same(200, loadedGameState.components.position[playerId].x)
    assert.are.same(300, loadedGameState.components.position[playerId].y)
  end)
end)
