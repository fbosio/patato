local controller

before_each(function ()
  controller = require "engine.systems.controller"
end)

after_each(function ()
  package.loaded.controller = nil
end)

describe("With one player with AD as walking input", function ()
  local keys, inputs, velocity, impulseSpeed

  before_each(function ()
    keys = {
      left = "a",
      right = "d"
    }
    inputs = {
      playerOne = {
        left = "left",
        right = "right"
      }
    }
    velocity = {
      playerOne = {x = 0, y = 0}
    }
    impulseSpeed = {
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
      controller.update(keys, inputs, velocity, impulseSpeed)

      assert.are.same(0, velocity.playerOne.x)
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

    it("should set the velocity to negative walk speed", function ()
      controller.update(keys, inputs, velocity, impulseSpeed)

      assert.are.same(-impulseSpeed.playerOne.walk, velocity.playerOne.x)
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

    it("should set the velocity to positive walk speed", function ()
      controller.update(keys, inputs, velocity, impulseSpeed)

      assert.are.same(impulseSpeed.playerOne.walk, velocity.playerOne.x)
    end)
  end)
end)

describe("With two players with AD and JL as walking input", function ()
  local keys, inputs, velocity, impulseSpeed

  before_each(function ()
    keys = {
      left = "a",
      right = "d",
      left2 = "j",
      right2 = "l"
    }
    inputs = {
      playerOne = {
        left = "left",
        right = "right"
      },
      playerTwo = {
        left = "left2",
        right = "right2"
      }
    }
    velocity = {
      playerOne = {x = 0, y = 0},
      playerTwo = {x = 0, y = 0}
    }
    impulseSpeed = {
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
      controller.update(keys, inputs, velocity, impulseSpeed)

      assert.are.same(0, velocity.playerOne.x)
      assert.are.same(0, velocity.playerTwo.x)
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
      controller.update(keys, inputs, velocity, impulseSpeed)

      assert.are.same(-impulseSpeed.playerOne.walk, velocity.playerOne.x)
      assert.are.same(0, velocity.playerTwo.x)
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
      controller.update(keys, inputs, velocity, impulseSpeed)

      assert.are.same(impulseSpeed.playerOne.walk, velocity.playerOne.x)
      assert.are.same(0, velocity.playerTwo.x)
    end)
  end)

  describe("pressing J key", function ()
    before_each(function ()
      local loveMock = {keyboard = {}}
      loveMock.keyboard.isDown = function (key)
        return key == "j"
      end
      controller.load(loveMock)
    end)

    it("should set player two velocity to negative walk speed", function ()
      controller.update(keys, inputs, velocity, impulseSpeed)

      assert.are.same(0, velocity.playerOne.x)
      assert.are.same(-impulseSpeed.playerTwo.walk, velocity.playerTwo.x)
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
      controller.update(keys, inputs, velocity, impulseSpeed)

      assert.are.same(0, velocity.playerOne.x)
      assert.are.same(impulseSpeed.playerTwo.walk, velocity.playerTwo.x)
    end)
  end)
end)
