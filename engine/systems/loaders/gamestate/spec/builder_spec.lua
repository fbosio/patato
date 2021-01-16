local builder, entityTagger, components

before_each(function ()
  builder = require "engine.systems.loaders.gamestate.builder"
  entityTagger = require "engine.tagger"
  local command = require "engine.command"
  local love = {graphics = {}}
  function love.graphics.getDimensions()
    return 800, 600
  end
  local loveMock = mock(love)
  components = {}
  local hid = {commands = {}}
  command.load(hid, components)
  builder.load(loveMock, entityTagger, command, false, components)
end)

after_each(function ()
  package.loaded["engine.systems.loaders.gamestate.builder"] = nil
  package.loaded["engine.systems.loaders.gamestate.component"] = nil
  package.loaded["engine.tagger"] = nil
end)

describe("loading a nonmenu controllable entity", function ()
  local playerId

  before_each(function ()
    local flags = {"controllable"}
    playerId = entityTagger.tag("player")

    builder.flags(flags, playerId)
  end)

  it("should create a component for the entity", function ()
    assert.is.truthy(components.controllable[playerId])
  end)

  it("should set default components to the entity", function ()
    assert.are.same({x = 400, y = 300}, components.position[playerId])
    assert.are.same({x = 0, y = 0}, components.velocity[playerId])
    assert.are.same({walk = 400}, components.impulseSpeed[playerId])
  end)
end)

describe("loading a controllable entity with a walk speed defined", function ()
  it("should not overwrite the speed", function ()
    local flags = {"controllable"}
    local impulseSpeed = {walk = 800}
    local playerId = entityTagger.tag("player")

    builder.flags(flags, playerId)
    builder.impulseSpeed(impulseSpeed, playerId)

    assert.are.same({walk = 800}, components.impulseSpeed[playerId])
  end)
end)

describe("loading an entity with impulse speeds", function ()
  it("should copy the define speeds to the component", function ()
    local impulseSpeed = {
      walk = 400,
      crouchWalk = 200,
      jump = 1200,
      climb = 400
    }
    local playerId = entityTagger.tag("player")

    builder.impulseSpeed(impulseSpeed, playerId)

    local playerSpeed = components.impulseSpeed[playerId]
    assert.are.same(400, playerSpeed.walk)
    assert.are.same(200, playerSpeed.crouchWalk)
    assert.are.same(1200, playerSpeed.jump)
    assert.are.same(400, playerSpeed.climb)
  end)
end)

describe("loading config with nonempty menu", function ()
  it("should copy the menu", function ()
    local menu = {
      options = {"Start"}
    }
    local mainMenuId = entityTagger.tag("mainMenu")

    builder.menu(menu, mainMenuId)

    assert.are.same({"Start"}, components.menu[mainMenuId].options)
  end)
end)

describe("loading a collision box", function ()
  local collisionBox, playerId

  before_each(function ()
    collisionBox = {15, 35, 30, 70}

    playerId = entityTagger.tag("player")
    builder.collisionBox(collisionBox, playerId)
  end)

  it("should copy the component", function ()
    local box = components.collisionBox[playerId]
    assert.are.same(15, box.origin.x)
    assert.are.same(35, box.origin.y)
    assert.are.same(30, box.width)
    assert.are.same(70, box.height)
  end)

  it("should create game state with default position", function ()
    local playerPosition = components.position[playerId]
    assert.are.same(400, playerPosition.x)
    assert.are.same(300, playerPosition.y)
  end)
end)

describe("loading an entity that has a wrong collideable type", function ()
  it("should throw an error", function ()
    local collideableWithTypo = "rectanlgbe"
    local surfaceId = entityTagger.tag("surface")

    assert.has_error(function ()
      builder.collideable(collideableWithTypo, surfaceId)
    end)
  end)
end)

describe("loading an entity with animations", function ()
  it("should create an animation component", function ()
    local resources = {
      animations = {
        standing = {1, 1},
        walking = {2, 0.5, 3, 0.5, 4, 0.5, 3, 0.5, true}
      }
    }

    local playerId = entityTagger.tag("player")
    builder.resources(resources, playerId)
    local playerAnimation = components.animation[playerId]
    assert.are.same(1, playerAnimation.frame)
    assert.are.same(0, playerAnimation.time)
    assert.are.falsy(playerAnimation.ended)
  end)
end)

describe("loading a collector entity", function ()
  local playerId

  before_each(function ()
    local flags = {"collector"}

    playerId = entityTagger.tag("player")
    builder.flags(flags, playerId)
  end)

  it("should copy the component", function ()
    assert.is.truthy(components.collector[playerId])
  end)

  it("should set default components to the entity", function ()
    assert.are.same({x = 400, y = 300}, components.position[playerId])
    assert.are.same({x = 0, y = 0}, components.velocity[playerId])
  end)
end)

describe("loading a solid entity", function ()
  local playerId

  before_each(function ()
    local flags = {"solid"}

    playerId = entityTagger.tag("player")
    builder.flags(flags, playerId)
  end)

  it("should copy the component", function ()
    assert.is.truthy(components.solid[playerId])
  end)

  it("should set default components to the entity", function ()
    assert.are.same({x = 400, y = 300}, components.position[playerId])
    assert.are.same({x = 0, y = 0}, components.velocity[playerId])
  end)
end)

describe("loading a gravitational entity", function ()
  local anvilId

  before_each(function ()
    local flags = {"gravitational"}

    anvilId = entityTagger.tag("anvil")
    builder.flags(flags, anvilId)
  end)

  it("should enable the component", function ()
    assert.is.truthy(components.gravitational[anvilId].enabled)
  end)

  it("should set default components to the entity", function ()
    assert.are.same({x = 400, y = 300}, components.position[anvilId])
    assert.are.same({x = 0, y = 0}, components.velocity[anvilId])
  end)
end)

describe("loading a climber entity", function ()
  local playerId

  before_each(function ()
    local flags = {"climber"}

    playerId = entityTagger.tag("player")
    builder.flags(flags, playerId)
  end)

  it("should copy the component", function ()
    assert.is.truthy(components.climber[playerId])
  end)

  it("should set default components to the entity", function ()
    assert.are.same({x = 400, y = 300}, components.position[playerId])
    assert.are.same({x = 0, y = 0}, components.velocity[playerId])
  end)
end)
