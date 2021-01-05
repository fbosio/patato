local controller, entityTaggerMock, command, hid, loveMock

before_each(function ()
  controller = require "engine.systems.controller"
  command = require "engine.command"
  hid = {
    keys = {
      left = "a",
      right = "d",
      left2 = "j",
      right2 = "l",
      up = "w",
      down = "s",
      start = "return"
    },
    joystick = {
      hats = {
        left = "l",
        right = "r",
        up = "u",
        down = "d"
      },
      buttons = {
        start = 10
      }
    },
    commands = {
      [command.new{key = "left"}] = {playerOne = "walkLeft"},
      [command.new{key = "left2"}] = {playerTwo = "walkLeft"},
      [command.new{key = "right"}] = {playerOne = "walkRight"},
      [command.new{key = "right2"}] = {playerTwo = "walkRight"},
      [command.new{key = "up"}] = {playerOne = "walkUp"},
      [command.new{key = "down"}] = {playerOne = "walkDown"},
      [command.new{keys = {"left", "right"}, release = true}] = {
        playerOne = "stopWalkingHorizontally"
      },
      [command.new{keys = {"left2", "right2"}, release = true}] = {
        playerTwo = "stopWalkingHorizontally"
      },
      [command.new{keys = {"up", "down"}, release = true}] = {
        playerOne = "stopWalkingVertically"
      },
      [command.new{key = "up", oneShot = true}] = {
        mainMenu = "menuPrevious"
      },
      [command.new{key = "down", oneShot = true}] = {
        mainMenu = "menuNext"
      },
      [command.new{key = "start", oneShot = true}] = {
        mainMenu = "menuSelect"
      },
      [command.new{keys = {"up", "down"}, oneShot = true}] = {
        playerOne = "startClimb"
      }
    },
    actions = {
      walkLeft = function (c) c.velocity.x = -c.impulseSpeed.walk end,
      walkRight = function (c) c.velocity.x = c.impulseSpeed.walk end,
      walkUp = function (c) c.velocity.y = -c.impulseSpeed.walk end,
      walkDown = function (c) c.velocity.y = c.impulseSpeed.walk end,
      stopWalkingHorizontally = function (c) c.velocity.x = 0 end,
      stopWalkingVertically = function (c) c.velocity.y = 0 end,
      menuPrevious = function (c)
        c.menu.selected = c.menu.selected - 1
        if c.menu.selected == 0 then
          c.menu.selected = #c.menu.options
        end
      end,
      menuNext = function (c)
        c.menu.selected = c.menu.selected + 1
        if c.menu.selected == #c.menu.options + 1 then
          c.menu.selected = 1
        end
      end,
      menuSelect = function (c)
        (c.menu.callbacks[c.menu.selected] or function () end)()
      end,
      changeAnimationToWalking = function (c)
        c.animation.name = "walking"
      end,
      startClimb = function (c)
        c.climber.climbing = true
      end,
    }
  }
  entityTaggerMock = {}
  function entityTaggerMock.getIds(name)
    return {name}
  end
  loveMock = {
    keyboard = {isDown = function () end}
  }
end)

after_each(function ()
  package.loaded["engine.systems.controller"] = nil
  package.loaded["engine.command"] = nil
end)

describe("with one player with input for walking", function ()
  local components

  before_each(function ()
    components = {
      input = {
        playerOne = {
          walkLeft = false,
          walkRight = false,
          stopWalkingHorizontally = false,
          stopWalkingVertically = false
        }
      },
      velocity = {
        playerOne = {x = 0, y = 0}
      },
      impulseSpeed = {
        playerOne = {walk = 100}
      }
    }
  end)

  describe("without pressing any key", function ()    
    it("should set the velocity to zero", function ()
      loveMock.keyboard.isDown = function ()
        return false
      end
      controller.load(loveMock, entityTaggerMock)
      
      controller.update(hid, components)

      assert.are.same(0, components.velocity.playerOne.x)
    end)
  end)

  describe("pressing the key mapped to 'left'", function ()
    before_each(function ()
      loveMock.keyboard.isDown = function (key)
        return key == "a"
      end
      controller.load(loveMock, entityTaggerMock)
    end)

    it("should set the velocity to negative walk speed", function ()
      controller.update(hid, components)

      assert.are.same(-components.impulseSpeed.playerOne.walk,
                      components.velocity.playerOne.x)
    end)

    describe("and then leaving it", function ()      
      it("should set the velocity to zero", function ()
        controller.update(hid, components)
        controller.keyreleased("a", hid, components)
  
        loveMock.keyboard.isDown = function ()
          return false
        end

        controller.update(hid, components)

        assert.are.same(0, components.velocity.playerOne.x)
      end)
    end)
  end)

  describe("pressing the key mapped to 'right'", function ()
    before_each(function ()
      loveMock.keyboard.isDown = function (key)
        return key == "d"
      end
      controller.load(loveMock, entityTaggerMock)
    end)

    it("should set the velocity to positive walk speed", function ()
      controller.update(hid, components)

      assert.are.same(components.impulseSpeed.playerOne.walk,
                      components.velocity.playerOne.x)
    end)

    describe("and then leaving it", function ()
      it("should set the velocity to zero", function ()
        controller.update(hid, components)
        controller.keyreleased("a", hid, components)
        loveMock.keyboard.isDown = function ()
          return false
        end

        controller.update(hid, components)

        assert.are.same(0, components.velocity.playerOne.x)
      end)
    end)
  end)

  describe("without pressing any button", function ()    
    it("should set the velocity to zero", function ()
      local joystickMock = {}
      function joystickMock:isDown()
        return false
      end
      function joystickMock:getHat()
        return "c"
      end
      controller.load(loveMock, entityTaggerMock)
      controller.joystickadded(joystickMock, hid)
      
      controller.update(hid, components)

      assert.are.same(0, components.velocity.playerOne.x)
    end)
  end)

  describe("pressing the joystick hat mapped to 'left'", function ()
    local joystickMock

    before_each(function ()
      joystickMock = {}
      function joystickMock:getHat()
        return "l"
      end
      controller.load(loveMock, entityTaggerMock)
      controller.joystickadded(joystickMock, hid)
    end)

    it("should set the velocity to negative walk speed", function ()
      controller.update(hid, components)

      assert.are.same(-components.impulseSpeed.playerOne.walk,
                      components.velocity.playerOne.x)
    end)

    describe("and the joystick hat mapped to 'up'", function ()
      it("should set both velocities to negative walk speed", function ()
        function joystickMock:getHat()
          return "lu"
        end

        controller.update(hid, components)
        
        assert.are.same({
          x = -components.impulseSpeed.playerOne.walk,
          y = -components.impulseSpeed.playerOne.walk
        }, components.velocity.playerOne)
      end)
    end)

    describe("and then leaving it", function ()
      it("should set the velocity to zero", function ()
        controller.update(hid, components)
        controller.joystickhat(joystickMock, 1, "c", hid, components)
        
        function joystickMock:getHat()
          return "c"
        end
        
        controller.update(hid, components)

        assert.are.same(0, components.velocity.playerOne.x)
      end)
    end)
  end)

  describe("pressing the joystick hat mapped to 'right'", function ()
    local joystickMock

    before_each(function ()
      joystickMock = {}
      function joystickMock:getHat()
        return "r"
      end
      controller.load(loveMock, entityTaggerMock)
      controller.joystickadded(joystickMock, hid)
    end)

    it("should set the velocity to positive walk speed", function ()
      controller.update(hid, components)

      assert.are.same(components.impulseSpeed.playerOne.walk,
                      components.velocity.playerOne.x)
    end)

    describe("and then leaving it", function ()
      before_each(function ()
        controller.update(hid, components)
        controller.joystickhat(joystickMock, 1, "c", hid, components)
        
        function joystickMock:getHat()
          return "c"
        end
      end)

      it("should set the velocity to zero", function ()
        controller.update(hid, components)

        assert.are.same(0, components.velocity.playerOne.x)
      end)
    end)
  end)
end)

describe("with two players with AD and JL as walking input", function ()
  local components

  before_each(function ()
    components = {
      input = {
        playerOne = {
          walkLeft = false,
          walkRight = false,
          stopWalkingHorizontally = false
        },
        playerTwo = {
          walkLeft = false,
          walkRight = false,
          stopWalkingHorizontally = false
        }
      },
      velocity = {
        playerOne = {x = 0, y = 0},
        playerTwo = {x = 0, y = 0}
      },
      impulseSpeed = {
        playerOne = {walk = 100},
        playerTwo = {walk = 150}
      }
    }
  end)

  describe("without pressing any key", function ()
    before_each(function ()
      loveMock.keyboard.isDown = function ()
        return false
      end
      controller.load(loveMock, entityTaggerMock)
    end)

    it("should set both velocity to zero", function ()
      controller.update(hid, components)

      assert.are.same(0, components.velocity.playerOne.x)
      assert.are.same(0, components.velocity.playerTwo.x)
    end)
  end)

  describe("pressing A key", function ()
    before_each(function ()
      loveMock.keyboard.isDown = function (key)
        return key == "a"
      end
      controller.load(loveMock, entityTaggerMock)
    end)

    it("should set player one velocity to negative walk speed", function ()
      controller.update(hid, components)

      assert.are.same(-components.impulseSpeed.playerOne.walk,
                      components.velocity.playerOne.x)
      assert.are.same(0, components.velocity.playerTwo.x)
    end)
  end)

  describe("pressing D key", function ()
    before_each(function ()
      loveMock.keyboard.isDown = function (key)
        return key == "d"
      end
      controller.load(loveMock, entityTaggerMock)
    end)

    it("should set player one velocity to positive walk speed", function ()
      controller.update(hid, components)

      assert.are.same(components.impulseSpeed.playerOne.walk,
                      components.velocity.playerOne.x)
      assert.are.same(0, components.velocity.playerTwo.x)
    end)
  end)

  describe("pressing J key", function ()
    before_each(function ()
      loveMock.keyboard.isDown = function (key)
        return key == "j"
      end
      controller.load(loveMock, entityTaggerMock)
    end)

    it("should set player two velocity to negative walk speed", function ()
      controller.update(hid, components)

      assert.are.same(0, components.velocity.playerOne.x)
      assert.are.same(-components.impulseSpeed.playerTwo.walk,
                      components.velocity.playerTwo.x)
    end)

    describe("and then leaving it", function ()
      before_each(function ()
        controller.update(hid, components)
        controller.keyreleased("j", hid, components)
        loveMock.keyboard.isDown = function ()
          return false
        end
      end)

      it("should set player two velocity to zero", function ()
        controller.update(hid, components)

        assert.are.same(0, components.velocity.playerTwo.x)
      end)
    end)
  end)

  describe("pressing L key", function ()
    before_each(function ()
      loveMock.keyboard.isDown = function (key)
        return key == "l"
      end
      controller.load(loveMock, entityTaggerMock)
    end)

    it("should set player two velocity to positive walk speed", function ()
      controller.update(hid, components)

      assert.are.same(0, components.velocity.playerOne.x)
      assert.are.same(components.impulseSpeed.playerTwo.walk, components.velocity.playerTwo.x)
    end)
  end)
end)

describe("with a menu", function ()
  local components, started, joystickMock

  before_each(function ()
    components = {
      input = {
        mainMenu = {
          menuPrevious = false,
          menuNext = false,
          menuSelect = false
        }
      },
      menu = {
        mainMenu = {
          options = {"Start", "Options", "Help"},
          callbacks = {function ()
            started = true
          end},
          selected = 1
        }
      }
    }
    started = false
    joystickMock = {}
    controller.load({}, entityTaggerMock)
    controller.joystickadded(joystickMock, hid)
  end)

  describe("pressing the key mapped to 'down'", function ()
    it("should select the second menu option", function ()
      controller.keypressed("s", hid, components)

      assert.are.same(2, components.menu.mainMenu.selected)
    end)
  end)

  describe("pressing the key mapped to 'up'", function ()
    it("should select the third menu option", function ()
      controller.keypressed("w", hid, components)

      assert.are.same(3, components.menu.mainMenu.selected)
    end)
  end)

  describe("pressing the key mapped to 'start'", function ()
    it("should run the callback of the first menu option", function ()
      controller.keypressed("return", hid, components)

      assert.is.truthy(started)
    end)
  end)

  describe("pressing the joystick hat mapped to 'down'", function ()
    it("should select the second menu option", function ()
      controller.joystickhat(joystickMock, 1, "d", hid, components)

      assert.are.same(2, components.menu.mainMenu.selected)
    end)
  end)

  describe("pressing the joystick hat mapped to 'up'", function ()
    it("should select the third menu option", function ()
      controller.joystickhat(joystickMock, 1, "u", hid, components)

      assert.are.same(3, components.menu.mainMenu.selected)
    end)
  end)

  describe("pressing the joystick button mapped to 'start'", function ()
    it("should run the callback of the first menu option", function ()
      controller.joystickpressed(joystickMock, 10, hid, components)

      assert.is.truthy(started)
    end)
  end)
end)

describe("loading a player with animation and one without it", function ()
  local components

  before_each(function ()
    components = {
      input = {
        playerOne = {
          changeAnimationToWalking = false
        }
      },
      velocity = {
        playerOne = {x = 0, y = 0}
      },
      impulseSpeed = {
        playerOne = {walk = 400}
      },
      animation = {
        playerOne = {name = "idle"}
      },
    }
    hid.commands[command.new{key = "right"}] = {
      playerOne = "changeAnimationToWalking"
    }
  end)

  describe("and pressing D key", function ()
    it("should change player one animation", function ()
      loveMock.keyboard.isDown = function (key)
        return key == "d"
      end
      controller.load(loveMock, entityTaggerMock)
      
      controller.update(hid, components)

      assert.are.same("walking", components.animation.playerOne.name)
    end)
  end)
end)

describe("loading a climber player", function ()
  local components

  before_each(function ()
    components = {
      input = {
        playerOne = {
          startClimb = false
        }
      },
      velocity = {
        playerOne = {x = 0, y = 0}
      },
      impulseSpeed = {
        playerOne = {walk = 400}
      },
      climber = {
        playerOne = {climbing = false}
      }
    }
  end)

  describe("and pressing W key", function ()
    it("should start climbing", function ()
      controller.load({}, entityTaggerMock)
      
      controller.keypressed("w", hid, components)

      assert.is.truthy(components.climber.playerOne.climbing)
    end)
  end)

  describe("and pressing S key", function ()
    it("should start climbing", function ()
      controller.load({}, entityTaggerMock)
      
      controller.keypressed("s", hid, components)

      assert.is.truthy(components.climber.playerOne.climbing)
    end)
  end)
end)
