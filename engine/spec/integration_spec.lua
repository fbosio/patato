describe("Loading 3 levels with players, a menu with 4 options", function ()
  local resourcemanager, controller, config, world, drankCoffee

  before_each(function ()
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
        },
        first = "green hill zone"
      }
    }
    local loveMock = {graphics = {}}
    function loveMock.graphics.getDimensions()
      return 800, 600
    end
    controller.load(loveMock)
    resourcemanager.load(loveMock)
    world = resourcemanager.buildWorld(config)
    drankCoffee = false
    world.gameState.menu.mainMenu.callbacks = {
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
    package.loaded.controller = nil
    package.loaded.resourcemanager = nil
  end)

  describe("and selecting the 'go to first level' option", function ()
    it("should place the player according to the first level", function ()
      controller.keypressed("return", world.keys, world.gameState.input,
                            world.gameState.menu, world.inMenu)

      local firstLevel = config.levels[config.levels.first]
      local playerPosition = world.gameState.position.sonic
      assert.are.same(firstLevel.sonic[1], playerPosition.x)
      assert.are.same(firstLevel.sonic[2], playerPosition.y)
    end)
  end)

  describe("and selecting the 'go to second level' option", function ()
    it("should place the player according to the second level", function ()
      controller.keypressed("s", world.keys, world.gameState.input,
                            world.gameState.menu, world.inMenu)
      controller.keypressed("return", world.keys, world.gameState.input,
                            world.gameState.menu, world.inMenu)

      local level = config.levels["hill top zone"]
      local playerPosition = world.gameState.position.sonic
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
      local playerPosition = world.gameState.position.sonic
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