describe("loading 3 levels with players, a menu with 4 options", function ()
  local entityTagger, command, loveMock
  local resourcemanager, controller, config, world, drankCoffee

  before_each(function ()
    entityTagger = require "engine.tagger"
    command = require "engine.command"
    resourcemanager = require "engine.resourcemanager"
    controller = require "engine.systems.controller"
    config = {
      keys = {
        start = "return"
      },
      entities = {
        sonic = {
          input = true
        },
        mainMenu = {
          input = true,
          menu = {
            options = {
              "Go to Green hill zone",
              "Go to Hill top zone",
              "Go to Metropolis Zone",
              "Drink coffee"
            }
          }
        }
      },
      levels = {
        ["green hill zone"] = {
          sonic = {378, 287}
        },
        ["hill top zone"] = {
          sonic = {750, 100}
        },
        ["metropolis zone"] = {
          sonic = {200, 500}
        }
      },
      firstLevel = "green hill zone"
    }
    loveMock = {graphics = {}, keyboard = {}}
    function loveMock.graphics.getDimensions()
      return 800, 600
    end
    controller.load(loveMock, entityTagger)
    resourcemanager.load(loveMock, entityTagger)
    world = resourcemanager.buildWorld(config)
    resourcemanager.setInputs(world, "sonic", {
      walkLeft = command.new{key = "left"}
    })
    resourcemanager.setInputs(world, "mainMenu", {
      menuPrevious = command.new{key = "up", oneShot = true},
      menuNext = command.new{key = "down", oneShot = true},
      menuSelect = command.new{key = "start", oneShot = true}
    })
    drankCoffee = false
    local mainMenuId = entityTagger.getId("mainMenu")
    world.gameState.components.menu[mainMenuId].callbacks = {
      function ()
        world.gameState.inMenu = false
        resourcemanager.buildState(config, world)
      end,
      function ()
        world.gameState.inMenu = false
        resourcemanager.buildState(config, world, "hill top zone")
      end,
      function ()
        world.gameState.inMenu = false
        resourcemanager.buildState(config, world, "metropolis zone")
      end,
      function ()
        drankCoffee = true
      end,
    }
  end)

  after_each(function ()
    package.loaded["engine.systems.controller"] = nil
    package.loaded["engine.resourcemanager"] = nil
    package.loaded["engine.tagger"] = nil
    package.loaded["engine.command"] = nil
  end)

  describe("and selecting the 'go to first level' option", function ()
    before_each(function ()
      controller.keypressed("return", world.hid, world.gameState.components)
    end)

    it("should place the player according to the first level", function ()
      local level = config.levels["green hill zone"]
      local playerId = entityTagger.getId("sonic")
      local playerPosition = world.gameState.components.position[playerId]
      assert.are.same(level.sonic[1], playerPosition.x)
      assert.are.same(level.sonic[2], playerPosition.y)
    end)

    describe("and pressing the A key", function ()
      it("should make the player walk", function ()
        function loveMock.keyboard.isDown(key)
          return key == "a"
        end

        controller.update(world.hid, world.gameState.components)

        local playerId = entityTagger.getId("sonic")
        local playerVelocity = world.gameState.components.velocity[playerId]
        local playerSpeed = world.gameState.components.impulseSpeed[playerId]
        assert.are.same(-playerSpeed.walk, playerVelocity.x)
      end)
    end)
  end)

  describe("and selecting the 'go to second level' option", function ()
    it("should place the player according to the second level", function ()
      controller.keypressed("s", world.hid, world.gameState.components)
      controller.keypressed("return", world.hid, world.gameState.components)

      local level = config.levels["hill top zone"]
      local playerId = entityTagger.getId("sonic")
      local playerPosition = world.gameState.components.position[playerId]
      assert.are.same(level.sonic[1], playerPosition.x)
      assert.are.same(level.sonic[2], playerPosition.y)
    end)
  end)

  describe("and selecting the 'go to third level' option", function ()
    it("should place the player according to the third level", function ()
      controller.keypressed("s", world.hid, world.gameState.components)
      controller.keypressed("s", world.hid, world.gameState.components)
      controller.keypressed("return", world.hid, world.gameState.components)

      local level = config.levels["metropolis zone"]
      local playerId = entityTagger.getId("sonic")
      local playerPosition = world.gameState.components.position[playerId]
      assert.are.same(level.sonic[1], playerPosition.x)
      assert.are.same(level.sonic[2], playerPosition.y)
    end)
  end)

  describe("and selecting the 'drink coffee' option", function ()
    it("should show that the coffee was drunk", function ()
      controller.keypressed("s", world.hid, world.gameState.components)
      controller.keypressed("s", world.hid, world.gameState.components)
      controller.keypressed("s", world.hid, world.gameState.components)
      controller.keypressed("return", world.hid, world.gameState.components)

      assert.is.truthy(drankCoffee)
    end)
  end)
end)
