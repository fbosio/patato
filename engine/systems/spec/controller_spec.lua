local controller, entityTaggerMock, hid, loveMock, joystickMock

before_each(function ()
  controller = require "engine.systems.controller"
  hid = {
    keys = {
      left = "a"
    },
    joystick = {
      hats = {
        left = "l"
      },
      buttons = {
        run = 1
      }
    },
    commands = {
      hold = {
        left = false,
        run = false
      },
      press = {
        left = false,
        run = false
      },
      release = {
        left = false,
        run = false
      }
    }
  }
  entityTaggerMock = {}
  function entityTaggerMock.getIds(name)
    return {name}
  end
  loveMock = {
    keyboard = {isDown = function () end}
  }
  joystickMock = {
    getHat = function () return "c" end,
    isDown = function () end
  }
end)

after_each(function ()
  package.loaded["engine.systems.controller"] = nil
end)

describe("without pressing any input", function ()
  it("should not trigger any command", function ()
    controller.load(loveMock, entityTaggerMock)
    controller.update(hid)

    assert.are.same({
      hold = {
        left = false,
        run = false
      },
      press = {
        left = false,
        run = false
      },
      release = {
        left = false,
        run = false
      }
    }, hid.commands)
  end)
end)

describe("pressing the key mapped to 'left'", function ()
  before_each(function ()
    controller.load(loveMock, entityTaggerMock)
    function loveMock.keyboard.isDown(key)
      return key == "a"
    end

    controller.keypressed("a", hid)
  end)

  it("should trigger the 'press left' command", function ()
    assert.is.truthy(hid.commands.press.left)
  end)

  describe("and then holding it", function ()
    before_each(function ()
      controller.update(hid)
    end)

    it("should trigger the 'hold left' command", function ()
      assert.is.truthy(hid.commands.hold.left)
    end)

    it("should not trigger the 'press left' command", function ()
      assert.is.falsy(hid.commands.press.left)
    end)
  end)

  describe("and then leaving it", function ()
    before_each(function ()
      function loveMock.keyboard.isDown()
        return false
      end
      controller.keyreleased("a", hid)
    end)
    
    it("should trigger the 'release left' command", function ()
      assert.is.truthy(hid.commands.release.left)
    end)

    it("should not trigger 'press left' and 'hold left'", function ()
      assert.is.falsy(hid.commands.press.left)
      assert.is.falsy(hid.commands.hold.left)
    end)
  end)
end)

describe("pressing the joystick hat mapped to 'left'", function ()
  before_each(function ()
    controller.joystickadded(joystickMock, hid)
    controller.load(loveMock, entityTaggerMock)
    function joystickMock.getHat()
      return "l"
    end

    controller.joystickhat(joystickMock, 1, "l", hid)
  end)

  it("should trigger the 'press left' command", function ()
    assert.is.truthy(hid.commands.press.left)
  end)

  describe("and then holding it", function ()
    before_each(function ()
      controller.update(hid)
    end)

    it("should trigger the 'hold left' command", function ()
      assert.is.truthy(hid.commands.hold.left)
    end)

    it("should not trigger the 'press left' command", function ()
      assert.is.falsy(hid.commands.press.left)
    end)
  end)

  describe("and then leaving it", function ()
    before_each(function ()
      controller.joystickhat(joystickMock, 1, "c", hid)
    end)

    it("should trigger the 'release left' command", function ()
      assert.is.truthy(hid.commands.release.left)
    end)

    it("should not trigger 'press left' and 'hold left'", function ()
      assert.is.falsy(hid.commands.press.left)
      assert.is.falsy(hid.commands.hold.left)
    end)
  end)
end)

describe("pressing the joystick button mapped to 'run'", function ()
  before_each(function ()
    controller.joystickadded(joystickMock, hid)
    controller.load(loveMock, entityTaggerMock)
    function joystickMock:isDown(button)
      return button == 1
    end

    controller.joystickpressed(joystickMock, 1, hid)
  end)

  it("should trigger the 'press run' command", function ()
    assert.is.truthy(hid.commands.press.run)
  end)

  describe("and then holding it", function ()
    before_each(function ()
      controller.update(hid)
    end)

    it("should trigger the 'hold run' command", function ()
      assert.is.truthy(hid.commands.hold.run)
    end)

    it("should not trigger the 'press run' command", function ()
      assert.is.falsy(hid.commands.press.run)
    end)
  end)
  
  describe("and then leaving it", function ()
    before_each(function ()
      controller.joystickreleased(joystickMock, 1, hid)
    end)

    it("should trigger the 'release run' command", function ()
      assert.is.truthy(hid.commands.release.run)
    end)

    it("should not trigger 'press run' and 'hold run'", function ()
      assert.is.falsy(hid.commands.press.run)
      assert.is.falsy(hid.commands.hold.run)
    end)
  end)
end)
