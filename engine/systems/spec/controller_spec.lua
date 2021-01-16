local controller, entityTaggerMock, command, hid, loveMock, joystickMock,
      actionsMock, components

before_each(function ()
  controller = require "engine.systems.controller"
  command = require "engine.command"
  hid = {
    keys = {
      left = "a",
      right = "d",
      jump = "space",
      run = "shift"
    },
    joystick = {
      hats = {
        left = "l",
        right = "r",
        up = "u",
        down = "d"
      },
      buttons = {
        jump = 1,
        run = 2
      }
    }
  }
  local actions = {}
  for _, action in ipairs{"walkLeft", "walkRight", "stopWalkingLeft",
                          "jump", "run", "stopRunning", "startClimb"} do
    actions[action] = function () end
  end
  actionsMock = mock(actions)
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
  components = {
    controllable = {player = {}}
  }
  command.load(hid, components)
  command.set("player", "left", actionsMock.walkLeft, "hold")
  command.set("player", "left", actionsMock.stopWalkingLeft, "release")
  command.set("player", "jump", actionsMock.jump, "press")
  command.set("player", "run", actionsMock.run, "hold")
  command.set("player", "run", actionsMock.stopRunning, "release")
  command.set("player", "up", actionsMock.startClimb, "press")
  command.update("player", "player")
end)

after_each(function ()
  package.loaded["engine.systems.controller"] = nil
  package.loaded["engine.command"] = nil
end)

describe("with a player with movement, jump and run commands", function ()
  describe("without pressing any key", function ()
    it("should not call any actions", function ()
      controller.load(loveMock, entityTaggerMock)
            
      controller.update(hid, components)

      assert.stub(actionsMock.walkLeft).was_not.called()
      assert.stub(actionsMock.walkRight).was_not.called()
      assert.stub(actionsMock.stopWalkingLeft).was_not.called()
      assert.stub(actionsMock.jump).was_not.called()
      assert.stub(actionsMock.run).was_not.called()
      assert.stub(actionsMock.stopRunning).was_not.called()
    end)
  end)

  describe("pressing the key mapped to 'left'", function ()
    before_each(function ()
      controller.load(loveMock, entityTaggerMock)
      function loveMock.keyboard.isDown(key)
        return key == "a"
      end
      controller.keypressed("a", hid, components)
      controller.update(hid, components)
    end)

    it("should make the player walking left", function ()
      assert.stub(actionsMock.walkLeft).was.called()
    end)

    describe("and then holding it", function ()
      it("should keep the player walking left", function ()
        controller.update(hid, components)
  
        assert.stub(actionsMock.walkLeft).was.called()
        assert.stub(actionsMock.stopWalkingLeft).was_not.called()
      end)
    end)

    describe("and then leaving it", function ()
      it("should stop the player", function ()
        function loveMock.keyboard.isDown()
          return false
        end
        controller.keyreleased("a", hid, components)
        controller.update(hid, components)
  
        assert.stub(actionsMock.stopWalkingLeft).was.called()
      end)
    end)
  end)

  describe("pressing the key mapped to 'jump'", function ()
    before_each(function ()
      controller.load(loveMock, entityTaggerMock)
      function loveMock.keyboard.isDown(key)
        return key == "space"
      end
      controller.keypressed("space", hid, components)
      controller.update(hid, components)
    end)

    it("should make the player jump", function ()
      assert.stub(actionsMock.jump).was.called()
    end)

    describe("and then holding it", function ()
      it("should make the player jump once", function ()
        controller.update(hid, components)

        assert.stub(actionsMock.jump).was.called(1)
      end)
    end)
  end)

  describe("without pressing any joystick hat", function ()
    it("should not call any actions", function ()
      controller.load(loveMock, entityTaggerMock)
      controller.joystickadded(joystickMock, hid)

      controller.update(hid, components)

      assert.stub(actionsMock.walkLeft).was_not.called()
      assert.stub(actionsMock.walkRight).was_not.called()
      assert.stub(actionsMock.stopWalkingLeft).was_not.called()
      assert.stub(actionsMock.jump).was_not.called()
      assert.stub(actionsMock.run).was_not.called()
      assert.stub(actionsMock.stopRunning).was_not.called()
    end)
  end)

  describe("pressing the joystick hat mapped to 'left'", function ()
    before_each(function ()
      controller.joystickadded(joystickMock, hid)
      controller.load(loveMock, entityTaggerMock)
      function joystickMock.getHat()
        return "l"
      end

      controller.joystickhat(joystickMock, 1, "l", hid, components)
      controller.update(hid, components)
    end)

    it("should make the player walking left", function ()
      assert.stub(actionsMock.walkLeft).was.called()
    end)

    describe("and then holding it", function ()
      it("should keep the player walking left", function ()
        controller.update(hid, components)
  
        assert.stub(actionsMock.walkLeft).was.called()
        assert.stub(actionsMock.stopWalkingLeft).was_not.called()
      end)
    end)

    describe("and then leaving it", function ()
      it("should stop the player", function ()
        controller.joystickhat(joystickMock, 1, "c", hid, components)
        controller.update(hid, components)
  
        assert.stub(actionsMock.stopWalkingLeft).was.called()
      end)
    end)
  end)

  describe("pressing the joystick hat mapped to 'up'", function ()
    before_each(function ()
      controller.joystickadded(joystickMock, hid)
      controller.load(loveMock, entityTaggerMock)
      function joystickMock:getHat()
        return "u"
      end

      controller.joystickhat(joystickMock, 1, "u", hid, components)
      controller.update(hid, components)
    end)

    it("should make the player start climbing", function ()
      assert.stub(actionsMock.startClimb).was.called()
    end)

    describe("and then holding it", function ()
      it("should make the player climb once", function ()
        controller.update(hid, components)

        assert.stub(actionsMock.startClimb).was.called(1)
      end)
    end)
  end)

  describe("pressing the joystick button mapped to 'jump'", function ()
    before_each(function ()
      controller.joystickadded(joystickMock, hid)
      controller.load(loveMock, entityTaggerMock)
      function joystickMock:isDown(button)
        return button == 1
      end

      controller.joystickpressed(joystickMock, 1, hid, components)
      controller.update(hid, components)
    end)

    it("should make the player jump", function ()
      assert.stub(actionsMock.jump).was.called()
    end)

    describe("and then holding it", function ()
      it("should make the player jump once", function ()
        controller.update(hid, components)

        assert.stub(actionsMock.jump).was.called(1)
      end)
    end)
  end)

  describe("pressing the joystick button mapped to 'run'", function ()
    before_each(function ()
      controller.joystickadded(joystickMock, hid)
      controller.load(loveMock, entityTaggerMock)
      function joystickMock:isDown(button)
        return button == 2
      end

      controller.joystickpressed(joystickMock, 2, hid, components)
      controller.update(hid, components)
    end)

    it("should make the player run", function ()
      assert.stub(actionsMock.run).was.called()
    end)

    describe("and then holding it", function ()
      it("should keep the player running", function ()
        controller.update(hid, components)
  
        assert.stub(actionsMock.run).was.called()
        assert.stub(actionsMock.stopRunning).was_not.called()
      end)
    end)

    describe("and then leaving it", function ()
      it("should stop the player", function ()
        controller.joystickreleased(joystickMock, 2, hid, components)
        controller.update(hid, components)
  
        assert.stub(actionsMock.stopRunning).was.called()
      end)
    end)
  end)
end)
