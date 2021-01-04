local controller, entityTaggerMock, command, hid

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
    commands = {
      [command.new{key = "left"}] = {playerOne = "walkLeft"},
      [command.new{key = "left2"}] = {playerTwo = "walkLeft"},
      [command.new{key = "right"}] = {playerOne = "walkRight"},
      [command.new{key = "right2"}] = {playerTwo = "walkRight"},
      [command.new{keys = {"left", "right"}, release = true}] = {
        playerOne = "stopWalkingHorizontally"
      },
      [command.new{keys = {"left2", "right2"}, release = true}] = {
        playerTwo = "stopWalkingHorizontally"
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
end)

after_each(function ()
  package.loaded["engine.systems.controller"] = nil
  package.loaded["engine.command"] = nil
end)

describe("with one player with AD as walking input", function ()
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
    before_each(function ()
      local loveMock = {keyboard = {}}
      loveMock.keyboard.isDown = function ()
        return false
      end
      controller.load(loveMock, entityTaggerMock)
    end)

    it("should set the velocity to zero", function ()
      controller.update(hid, components)

      assert.are.same(0, components.velocity.playerOne.x)
    end)
  end)

  describe("pressing A key", function ()
    local loveMock = {keyboard = {}}

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
      before_each(function ()
        controller.update(hid, components)
        controller.keyreleased("a", hid, components)

        loveMock.keyboard.isDown = function ()
          return false
        end
      end)

      it("should set the velocity to zero", function ()
        controller.update(hid, components)

        assert.are.same(0, components.velocity.playerOne.x)
      end)
    end)
  end)

  describe("pressing D key", function ()
    local loveMock = {keyboard = {}}

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
      before_each(function ()
        controller.update(hid, components)
        controller.keyreleased("a", hid, components)

        loveMock.keyboard.isDown = function ()
          return false
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
      local loveMock = {keyboard = {}}
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
      local loveMock = {keyboard = {}}
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
      local loveMock = {keyboard = {}}
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
    local loveMock = {keyboard = {}}

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
      local loveMock = {keyboard = {}}
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
  local components, started

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
    controller.load({}, entityTaggerMock)
  end)

  describe("pressing S key", function ()
    it("should select the second menu option", function ()
      controller.keypressed("s", hid, components)

      assert.are.same(2, components.menu.mainMenu.selected)
    end)
  end)

  describe("pressing W key", function ()
    it("should select the third menu option", function ()
      controller.keypressed("w", hid, components)

      assert.are.same(3, components.menu.mainMenu.selected)
    end)
  end)

  describe("pressing RETURN key", function ()
    it("should run the callback of the first menu option", function ()
      controller.keypressed("return", hid, components)

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
      local loveMock = {keyboard = {}}
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
