describe("loading 3 levels with players, a menu with 4 options", function ()
  local entityTagger, animationTagger
  local resourcemanager, controller, config, world, drankCoffee

  before_each(function ()
    entityTagger = require "engine.tagger.entity"
    animationTagger = require "engine.tagger.animation"
    resourcemanager = require "engine.resourcemanager"
    controller = require "engine.systems.controller"
    config = {
      keys = {
        start = "return"
      },
      entities = {
        sonic = {
          input = {}
        },
        mainMenu = {
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
    local loveMock = {graphics = {}}
    function loveMock.graphics.getDimensions()
      return 800, 600
    end
    controller.load(loveMock)
    resourcemanager.load(loveMock, entityTagger, animationTagger)
    world = resourcemanager.buildWorld(config)
    drankCoffee = false
    local mainMenuId = entityTagger.getId("mainMenu")
    world.gameState.menu[mainMenuId].callbacks = {
      function ()
        world.inMenu = false
        resourcemanager.buildState(config, world)
      end,
      function ()
        world.inMenu = false
        resourcemanager.buildState(config, world, "hill top zone")
      end,
      function ()
        world.inMenu = false
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
    package.loaded["engine.tagger.entity"] = nil
    package.loaded["engine.tagger.animation"] = nil
  end)

  describe("and selecting the 'go to first level' option", function ()
    it("should place the player according to the first level", function ()
      controller.keypressed("return", world.keys, world.gameState.input,
                            world.gameState.menu, world.inMenu)

      local level = config.levels["green hill zone"]
      local playerId = entityTagger.getId("sonic")
      local playerPosition = world.gameState.position[playerId]
      assert.are.same(level.sonic[1], playerPosition.x)
      assert.are.same(level.sonic[2], playerPosition.y)
    end)
  end)

  describe("and selecting the 'go to second level' option", function ()
    it("should place the player according to the second level", function ()
      controller.keypressed("s", world.keys, world.gameState.input,
                            world.gameState.menu, world.inMenu)
      controller.keypressed("return", world.keys, world.gameState.input,
                            world.gameState.menu, world.inMenu)

      local level = config.levels["hill top zone"]
      local playerId = entityTagger.getId("sonic")
      local playerPosition = world.gameState.position[playerId]
      assert.are.same(level.sonic[1], playerPosition.x)
      assert.are.same(level.sonic[2], playerPosition.y)
    end)
  end)

  describe("and selecting the 'go to third level' option", function ()
    it("should place the player according to the third level", function ()
      controller.keypressed("s", world.keys, world.gameState.input,
                            world.gameState.menu, world.inMenu)
      controller.keypressed("s", world.keys, world.gameState.input,
                            world.gameState.menu, world.inMenu)
      controller.keypressed("return", world.keys, world.gameState.input,
                            world.gameState.menu, world.inMenu)

      local level = config.levels["metropolis zone"]
      local playerId = entityTagger.getId("sonic")
      local playerPosition = world.gameState.position[playerId]
      assert.are.same(level.sonic[1], playerPosition.x)
      assert.are.same(level.sonic[2], playerPosition.y)
    end)
  end)

  describe("and selecting the 'drink coffee' option", function ()
    it("should show that the coffee was drunk", function ()
      controller.keypressed("s", world.keys, world.gameState.input,
                            world.gameState.menu, world.inMenu)
      controller.keypressed("s", world.keys, world.gameState.input,
                            world.gameState.menu, world.inMenu)
      controller.keypressed("s", world.keys, world.gameState.input,
                            world.gameState.menu, world.inMenu)
      controller.keypressed("return", world.keys, world.gameState.input,
                            world.gameState.menu, world.inMenu)

      assert.is.truthy(drankCoffee)
    end)
  end)
end)
