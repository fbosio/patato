local hid

before_each(function ()
  hid = require "engine.systems.loaders.hid"
end)

after_each(function ()
  package.loaded["engine.systems.loaders.hid"] = nil
end)

describe("loading an empty config", function ()
  local emptyConfig = {}
  local loadedHid

  before_each(function ()
    emptyConfig = {}
    loadedHid = hid.load(emptyConfig)
  end)

  it("should map AWSD and return keys", function ()
    assert.are.same({
      left = "a",
      up = "w",
      down = "s",
      right = "d",
      start = "return"
    }, loadedHid.keys)
  end)

  it("should map the joystick hat", function ()
    assert.are.same({
      left = "l",
      right = "r",
      up = "u",
      down = "d"
    }, loadedHid.joystick.hats)
  end)

  it("should map the joystick START button", function ()
    assert.are.same(10, loadedHid.joystick.buttons.start)
  end)
end)

describe("loading an empty keys structure", function ()
  it("should load default movement and start keys", function ()
    local config = {
      inputs = {keyboard = {}}
    }

    local loadedHid = hid.load(config)

    assert.are.same({
      left = "a",
      up = "w",
      down = "s",
      right = "d",
      start = "return"
    }, loadedHid.keys)
  end)
end)

describe("loading all movement keys", function ()
  it("should copy the defined keys", function ()
    local config = {
      inputs = {
        keyboard = {
          left = "j",
          right = "l",
          up = "i",
          down = "k"
        }
      }
    }

    local loadedHid = hid.load(config)

    assert.are.same("j", loadedHid.keys.left)
    assert.are.same("l", loadedHid.keys.right)
    assert.are.same("i", loadedHid.keys.up)
    assert.are.same("k", loadedHid.keys.down)
  end)
end)

describe("loading some movement keys", function ()
  it("should fill lacking keys with default values", function ()
    local config = {
      inputs = {
        keyboard = {
          left = "j",
          down = "k"
        }
      }
    }

    local loadedHid = hid.load(config)

    assert.are.same({
      left = "j",
      right = "d",
      up = "w",
      down = "k",
      start = "return"
    }, loadedHid.keys)
  end)
end)

describe("loading some keys that are not for movement", function ()
  it("should copy the defined keys", function ()
    local config = {
      inputs = {
        keyboard = {
          ["super cool action 1"] = "j",
          ["super cool action 2"] = "k"
        }
      }
    }

    local loadedHid = hid.load(config)

    assert.are.same("j", loadedHid.keys["super cool action 1"])
    assert.are.same("k", loadedHid.keys["super cool action 2"])
  end)
end)

describe("loading an empty joystick structure", function ()
  it("should load default hats and a start button", function ()
    local config = {
      inputs = {joystick = {}}
    }

    local loadedHid = hid.load(config)

    assert.are.same({
      hats = {
        left = "l",
        right = "r",
        up = "u",
        down = "d"
      },
      buttons = {start = 10}
    }, loadedHid.joystick)
  end)
end)

describe("loading some buttons", function ()
  it("should fill lacking button with default value", function ()
    local config = {
      inputs = {
        joystick = {
          buttons = {
            jump = 1,
            run = 2
          }
        }
      }
    }

    local loadedHid = hid.load(config)

    assert.are.same({
      jump = 1,
      run = 2,
      start = 10
    }, loadedHid.joystick.buttons)
  end)
end)
