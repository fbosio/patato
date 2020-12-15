local controller

before_each(function ()
  controller = require "engine.systems.controller"
end)

after_each(function ()
  package.loaded.controller = nil
end)

describe("With one entity with movement input", function ()
  local keys, inputs, velocity, impulseSpeed

  before_each(function ()
    keys = {left = "a", right = "d"}
    inputs = {movableEntity = {left = "left", right = "right"}}
    velocity = {movableEntity = {x = 0, y = 0}}
    impulseSpeed = {movableEntity = {walk = 100}}
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

      assert.are.same(0, velocity.movableEntity.x)
    end)
  end)

  describe("pressing 'a' key", function ()
    before_each(function ()
      local loveMock = {keyboard = {}}
      loveMock.keyboard.isDown = function (key)
        return key == "a"
      end
      controller.load(loveMock)
    end)

    it("should set the velocity to negative walk speed", function ()
      controller.update(keys, inputs, velocity, impulseSpeed)

      assert.are.same(-100, velocity.movableEntity.x)
    end)
  end)

  describe("pressing 'd' key", function ()
    before_each(function ()
      local loveMock = {keyboard = {}}
      loveMock.keyboard.isDown = function (key)
        return key == "d"
      end
      controller.load(loveMock)
    end)

    it("should set the velocity to positive walk speed", function ()
      controller.update(keys, inputs, velocity, impulseSpeed)

      assert.are.same(100, velocity.movableEntity.x)
    end)
  end)
end)