local controller

before_each(function ()
  controller = require "engine.systems.controller"
end)

after_each(function ()
  package.loaded.controller = nil
end)

describe("with one player with AD as walking input", function ()
  local keys, inputs, velocities, impulseSpeeds

  before_each(function ()
    keys = {
      left = "a",
      right = "d"
    }
    inputs = {
      playerOne = {
        walkLeft = "left",
        walkRight = "right"
      }
    }
    velocities = {
      playerOne = {x = 0, y = 0}
    }
    impulseSpeeds = {
      playerOne = {walk = 100}
    }
  end)

  describe("without pressing any key", function ()
    before_each(function ()
      local loveMock = {keyboard = {}}
      loveMock.keyboard.isDown = function ()
        return false
      end
      controller.load(loveMock)
    end)

    it("should set the velocity to zero", function ()
      controller.update(keys, inputs, velocities, impulseSpeeds)

      assert.are.same(0, velocities.playerOne.x)
    end)
  end)

  describe("pressing A key", function ()
    local loveMock = {keyboard = {}}

    before_each(function ()
      loveMock.keyboard.isDown = function (key)
        return key == "a"
      end
      controller.load(loveMock)
    end)

    it("should set the velocity to negative walk speed", function ()
      controller.update(keys, inputs, velocities, impulseSpeeds)

      assert.are.same(-impulseSpeeds.playerOne.walk, velocities.playerOne.x)
    end)

    describe("and then leaving it", function ()
      before_each(function ()
        controller.update(keys, inputs, velocities, impulseSpeeds)

        loveMock.keyboard.isDown = function ()
          return false
        end
      end)

      it("should set the velocity to zero", function ()
        controller.update(keys, inputs, velocities, impulseSpeeds)

        assert.are.same(0, velocities.playerOne.x)
      end)
    end)
  end)

  describe("pressing D key", function ()
    local loveMock = {keyboard = {}}

    before_each(function ()
      loveMock.keyboard.isDown = function (key)
        return key == "d"
      end
      controller.load(loveMock)
    end)

    it("should set the velocity to positive walk speed", function ()
      controller.update(keys, inputs, velocities, impulseSpeeds)

      assert.are.same(impulseSpeeds.playerOne.walk, velocities.playerOne.x)
    end)

    describe("and then leaving it", function ()
      before_each(function ()
        controller.update(keys, inputs, velocities, impulseSpeeds)

        loveMock.keyboard.isDown = function ()
          return false
        end
      end)

      it("should set the velocity to zero", function ()
        controller.update(keys, inputs, velocities, impulseSpeeds)

        assert.are.same(0, velocities.playerOne.x)
      end)
    end)
  end)
end)

describe("with two players with AD and JL as walking input", function ()
  local keys, inputs, velocities, impulseSpeeds

  before_each(function ()
    keys = {
      left = "a",
      right = "d",
      left2 = "j",
      right2 = "l"
    }
    inputs = {
      playerOne = {
        walkLeft = "left",
        walkRight = "right"
      },
      playerTwo = {
        walkLeft = "left2",
        walkRight = "right2"
      }
    }
    velocities = {
      playerOne = {x = 0, y = 0},
      playerTwo = {x = 0, y = 0}
    }
    impulseSpeeds = {
      playerOne = {walk = 100},
      playerTwo = {walk = 150}
    }
  end)

  describe("without pressing any key", function ()
    before_each(function ()
      local loveMock = {keyboard = {}}
      loveMock.keyboard.isDown = function ()
        return false
      end
      controller.load(loveMock)
    end)

    it("should set both velocities to zero", function ()
      controller.update(keys, inputs, velocities, impulseSpeeds)

      assert.are.same(0, velocities.playerOne.x)
      assert.are.same(0, velocities.playerTwo.x)
    end)
  end)

  describe("pressing A key", function ()
    before_each(function ()
      local loveMock = {keyboard = {}}
      loveMock.keyboard.isDown = function (key)
        return key == "a"
      end
      controller.load(loveMock)
    end)

    it("should set player one velocity to negative walk speed", function ()
      controller.update(keys, inputs, velocities, impulseSpeeds)

      assert.are.same(-impulseSpeeds.playerOne.walk, velocities.playerOne.x)
      assert.are.same(0, velocities.playerTwo.x)
    end)
  end)

  describe("pressing D key", function ()
    before_each(function ()
      local loveMock = {keyboard = {}}
      loveMock.keyboard.isDown = function (key)
        return key == "d"
      end
      controller.load(loveMock)
    end)

    it("should set player one velocity to positive walk speed", function ()
      controller.update(keys, inputs, velocities, impulseSpeeds)

      assert.are.same(impulseSpeeds.playerOne.walk, velocities.playerOne.x)
      assert.are.same(0, velocities.playerTwo.x)
    end)
  end)

  describe("pressing J key", function ()
    local loveMock = {keyboard = {}}

    before_each(function ()
      loveMock.keyboard.isDown = function (key)
        return key == "j"
      end
      controller.load(loveMock)
    end)

    it("should set player two velocity to negative walk speed", function ()
      controller.update(keys, inputs, velocities, impulseSpeeds)

      assert.are.same(0, velocities.playerOne.x)
      assert.are.same(-impulseSpeeds.playerTwo.walk, velocities.playerTwo.x)
    end)

    describe("and then leaving it", function ()
      before_each(function ()
        controller.update(keys, inputs, velocities, impulseSpeeds)

        loveMock.keyboard.isDown = function ()
          return false
        end
      end)

      it("should set player two velocity to zero", function ()
        controller.update(keys, inputs, velocities, impulseSpeeds)

        assert.are.same(0, velocities.playerTwo.x)
      end)
    end)
  end)

  describe("pressing L key", function ()
    before_each(function ()
      local loveMock = {keyboard = {}}
      loveMock.keyboard.isDown = function (key)
        return key == "l"
      end
      controller.load(loveMock)
    end)

    it("should set player two velocity to positive walk speed", function ()
      controller.update(keys, inputs, velocities, impulseSpeeds)

      assert.are.same(0, velocities.playerOne.x)
      assert.are.same(impulseSpeeds.playerTwo.walk, velocities.playerTwo.x)
    end)
  end)
end)

describe("with a menu", function ()
  local keys, inputs, menus, started

  before_each(function ()
    keys = {
      up = "w",
      down = "s",
      start = "return"
    }
    inputs = {
      mainMenu = {
        menuPrevious = "up",
        menuNext = "down",
        menuSelect = "start"
      }
    }
    menus = {
      mainMenu = {
        options = {"Start", "Options", "Help"},
        callbacks = {function ()
          started = true
        end},
        selected = 1
      }
    }
  end)

  describe("pressing S key", function ()
    it("should select the second menu option", function ()
      controller.keypressed("s", keys, inputs, menus, true)

      assert.are.same(2, menus.mainMenu.selected)
    end)
  end)

  describe("pressing W key", function ()
    it("should select the third menu option", function ()
      controller.keypressed("w", keys, inputs, menus, true)

      assert.are.same(3, menus.mainMenu.selected)
    end)
  end)

  describe("pressing RETURN key", function ()
    it("should run the callback of the first menu option", function ()
      controller.keypressed("return", keys, inputs, menus, true)

      assert.is.truthy(started)
    end)
  end)
end)
