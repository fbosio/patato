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

describe("loading a collectable entity that is not in any level", function ()
  it("should not copy the component", function ()
    local config = {
      entities = {
        item = {
          flags = {"collectable"}
        }
      }
    }

    local loadedGameState = gamestate.load(loveMock, entityTagger, {}, config)

    assert.is.falsy(loadedGameState.components.collectable)
  end)
end)

describe("loading collectable entities that are in a level", function ()
  local config, loadedGameState

  before_each(function ()
    config = {
      entities = {
        bottle = {
          flags = {"collectable"}
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

    loadedGameState = gamestate.load(loveMock, entityTagger, {}, config)
  end)

  it("sould copy the collectable components with its name", function ()
    local collectable = loadedGameState.components.collectable
    assert.are.same("bottle", collectable[1].name)
    assert.are.same("bottle", collectable[2].name)
    assert.are.same("bottle", collectable[3].name)
  end)

  it("should copy the positions of the collectable components", function ()
    local position = loadedGameState.components.position
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
          flags = {"collector", "collectable"}
        }
      }
    }
  end)

  describe("without levels defined", function ()
    it("should throw an error", function ()
      assert.has_error(function ()
        gamestate.load(loveMock, entityTagger, {}, config)
      end)
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
      assert.has_error(function ()
        gamestate.load(loveMock, entityTagger, {}, config)
      end)
    end)
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

    local loadedGameState = gamestate.load(loveMock, entityTagger, {}, config)

    assert.is.falsy(loadedGameState.components.collideable)
  end)
end)

describe("loading surface entities that are in a level", function ()
  local loadedGameState

  before_each(function ()
    local config = {
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

    loadedGameState = gamestate.load(loveMock, entityTagger, {}, config)
  end)

  it("should copy the collideable components with its name", function ()
    local collideable = loadedGameState.components.collideable
    assert.are.same("surfaces", collideable[1].name)
    assert.are.same("surfaces", collideable[2].name)
  end)

  it("should create collision boxes for each entity", function ()
    assert.are.same({
      {origin = {x = 0, y = 0}, width = 300, height = 150},
      {origin = {x = 0, y = 0}, width = 300, height = 150},
    }, loadedGameState.components.collisionBox)
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
    local loadedGameState = gamestate.load(loveMock, entityTagger, {}, config)

    local collisionBox = loadedGameState.components.collisionBox
    assert.are.same({
      {origin = {x = 0, y = 0}, width = 300, height = 0},
      {origin = {x = 0, y = 0}, width = 300, height = 0},
    }, collisionBox)
  end)
end)

describe("loading slope entities that are in a level", function ()
  local config, loadedGameState

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

    loadedGameState = gamestate.load(loveMock, entityTagger, {}, config)
  end)

  it("should create collision boxes for each entity", function ()
    assert.are.same({
      {origin = {x = 0, y = 0}, width = 10, height = 10},
      {origin = {x = 0, y = 0}, width = 10, height = 10},
      {origin = {x = 0, y = 0}, width = 10, height = 10},
      {origin = {x = 0, y = 0}, width = 10, height = 10},
    }, loadedGameState.components.collisionBox)
  end)

  it("should create a collideable with slope attributes", function ()
    local collideable = loadedGameState.components.collideable
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

describe("loading an entity that is both collideable and solid", function ()
  local config
  before_each(function ()
    config = {
      entities = {
        absurdSpecimen = {
          collideable = "rectangle",
          flags = {"solid"}
        }
      }
    }
  end)

  describe("without levels defined", function ()
    it("should throw an error", function ()
      assert.has_error(function ()
        gamestate.load(loveMock, entityTagger, {}, config)
      end)
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
      assert.has_error(function ()
        gamestate.load(loveMock, entityTagger, {}, config)
      end)
    end)
  end)
end)

describe("loading a trellis entity that is not in any level", function ()
  it("should not copy the component", function ()
    local config = {
      entities = {
        trellis = {
          flags = {"trellis"}
        }
      }
    }

    local loadedGameState = gamestate.load(loveMock, entityTagger, {}, config)

    assert.is.falsy(loadedGameState.components.trellis)
  end)
end)

describe("loading trellis entities that are in a level", function ()
  local loadedGameState

  before_each(function ()
    local config = {
      entities = {
        trellises = {
          flags = {"trellis"}
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

    loadedGameState = gamestate.load(loveMock, entityTagger, {}, config)
  end)

  it("should copy the trellis components", function ()
    local trellis = loadedGameState.components.trellis
    assert.is.truthy(trellis[1])
    assert.is.truthy(trellis[2])
  end)

  it("should create collision boxes for each entity", function ()
    assert.are.same({
      {origin = {x = 0, y = 0}, width = 300, height = 150},
      {origin = {x = 0, y = 0}, width = 300, height = 150},
    }, loadedGameState.components.collisionBox)
  end)
end)

describe("loading an entity that is both climber and trellis", function ()
  local config
  before_each(function ()
    config = {
      entities = {
        absurdSpecimen = {
          flags = {"climber", "trellis"}
        }
      }
    }
  end)

  describe("without levels defined", function ()
    it("should throw an error", function ()
      assert.has_error(function ()
        gamestate.load(loveMock, entityTagger, {}, config)
      end)
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
      assert.has_error(function ()
        gamestate.load(loveMock, entityTagger, {}, config)
      end)
    end)
  end)
end)

describe("loading an entity that is both slope and trellis", function ()
  local config
  before_each(function ()
    config = {
      entities = {
        absurdSpecimen = {
          flags = {"trellis"},
          collideable = "triangle"
        }
      }
    }
  end)

  describe("without levels defined", function ()
    it("should throw an error", function ()
      assert.has_error(function ()
        gamestate.load(loveMock, entityTagger, {}, config)
      end)
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
      assert.has_error(function ()
        gamestate.load(loveMock, entityTagger, {}, config)
      end)
    end)
  end)
end)
