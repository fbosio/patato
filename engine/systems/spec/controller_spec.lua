local controller, hid

before_each(function ()
  controller = require "engine.systems.controller"
  local function defaultHorizontalOmission(c)
    c.velocity.x = 0
  end
  local function defaultVerticalOmission(c)
    c.velocity.y = 0
  end
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
    actions = {
      walkLeft = function (c) c.velocity.x = -c.impulseSpeed.walk end,
      walkRight = function (c) c.velocity.x = c.impulseSpeed.walk end,
      walkUp = function (c) c.velocity.y = -c.impulseSpeed.walk end,
      walkDown = function (c) c.velocity.y = c.impulseSpeed.walk end,
      menuPrevious = function (t)
        t.menu.selected = t.menu.selected - 1
        if t.menu.selected == 0 then
          t.menu.selected = #t.menu.options
        end
      end,
      menuNext = function (t)
        t.menu.selected = t.menu.selected + 1
        if t.menu.selected == #t.menu.options + 1 then
          t.menu.selected = 1
        end
      end,
      menuSelect = function (t)
        (t.menu.callbacks[t.menu.selected] or function () end)()
      end,
    },
    omissions = {
      [{"walkLeft", "walkRight"}] = defaultHorizontalOmission,
      [{"walkUp", "walkDown"}] = defaultVerticalOmission,
    }
  }
end)

after_each(function ()
  package.loaded["engine.systems.controller"] = nil
end)

describe("with one player with AD as walking input", function ()
  local components

  before_each(function ()
    components = {
      input = {
        playerOne = {
          walkLeft = "left",
          walkRight = "right"
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
      controller.load(loveMock)
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
      controller.load(loveMock)
    end)

    it("should set the velocity to negative walk speed", function ()
      controller.update(hid, components)

      assert.are.same(-components.impulseSpeed.playerOne.walk,
                      components.velocity.playerOne.x)
    end)

    describe("and then leaving it", function ()
      before_each(function ()
        controller.update(hid, components)

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
      controller.load(loveMock)
    end)

    it("should set the velocity to positive walk speed", function ()
      controller.update(hid, components)

      assert.are.same(components.impulseSpeed.playerOne.walk,
                      components.velocity.playerOne.x)
    end)

    describe("and then leaving it", function ()
      before_each(function ()
        controller.update(hid, components)

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
          walkLeft = "left",
          walkRight = "right"
        },
        playerTwo = {
          walkLeft = "left2",
          walkRight = "right2"
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
      controller.load(loveMock)
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
      controller.load(loveMock)
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
      controller.load(loveMock)
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
      controller.load(loveMock)
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
      controller.load(loveMock)
    end)

    it("should set player two velocity to positive walk speed", function ()
      controller.update(hid, components)

      assert.are.same(0, components.velocity.playerOne.x)
      assert.are.same(components.impulseSpeed.playerTwo.walk, components.velocity.playerTwo.x)
    end)
  end)
end)

describe("with a menu", function ()
  local inputs, menus, started

  before_each(function ()
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
      controller.keypressed("s", hid, inputs, menus, true)

      assert.are.same(2, menus.mainMenu.selected)
    end)
  end)

  describe("pressing W key", function ()
    it("should select the third menu option", function ()
      controller.keypressed("w", hid, inputs, menus, true)

      assert.are.same(3, menus.mainMenu.selected)
    end)
  end)

  describe("pressing RETURN key", function ()
    it("should run the callback of the first menu option", function ()
      controller.keypressed("return", hid, inputs, menus, true)

      assert.is.truthy(started)
    end)
  end)
end)
