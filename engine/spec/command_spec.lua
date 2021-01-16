local command, entityTagger, hid, marioId, luigiId, components

before_each(function ()
  command = require "engine.command"
  entityTagger = require "engine.tagger"
  marioId = entityTagger.tag("mario")
  luigiId = entityTagger.tag("luigi")
  hid = {}
  components = {
    controllable = {
      [marioId] = {},
      [luigiId] = {}
    }
  }
  command.load(entityTagger, hid, components)
end)

after_each(function ()
  package.loaded["engine.command"] = nil
  package.loaded["engine.tagger"] = nil
end)

describe("setting repeated commands for different entities", function ()
  local leftCallback, rightCallback

  before_each(function ()
    leftCallback = function (t)
      t.velocity.x = -t.impulseSpeed.walk
    end
    rightCallback = function (t)
      t.velocity.x = t.impulseSpeed.walk
    end
    
    command.set("mario", "left", leftCallback, "hold")
    command.set("mario", "right", rightCallback, "hold")
    command.set("luigi", "left", leftCallback, "hold")
    command.set("luigi", "right", rightCallback, "hold")
  end)

  it("should map the defined commands with the entities", function ()
    assert.are.same({
      left = leftCallback,
      right = rightCallback
    }, hid.commands.hold.mario)
    assert.are.same({
      left = leftCallback,
      right = rightCallback
    }, hid.commands.hold.luigi)
  end)

  it("should create an input set for each entity", function ()
    assert.are.same({
      left = false,
      right = false
    }, components.controllable[marioId].hold)
    assert.are.same({
      left = false,
      right = false
    }, components.controllable[luigiId].hold)
  end)
end)

describe("setting a command with a wrong kind", function ()
  it("should throw an error", function ()
    assert.has_error(function ()
      command.set("mario", "jump", function () end, "hofl")
    end)
  end)
end)

describe("setting a command for a noncontrollable entity", function ()
  it("should throw an error", function ()
    entityTagger.tag("anvil")
    assert.has_error(function ()
      command.set("anvil", "left", function () end, "hold")
    end)
  end)
end)
