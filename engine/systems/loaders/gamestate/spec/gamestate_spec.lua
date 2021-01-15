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

describe("loading a controllable entity", function ()
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
