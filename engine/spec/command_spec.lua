local command, entityTagger, hid, components

before_each(function ()
  command = require "engine.command"
  entityTagger = require "engine.tagger"

  hid = {}
  components = {}
  command.load(entityTagger, hid, components)
end)

after_each(function ()
  package.loaded["engine.command"] = nil
end)

describe("setting some hold commands for an entity", function ()
  local leftCallback, rightCallback, playerId
  
  before_each(function ()
    leftCallback = function (t)
      t.velocity.x = -t.impulseSpeed.walk
    end
    rightCallback = function (t)
      t.velocity.x = t.impulseSpeed.walk
    end
    playerId = entityTagger.tag("player")

    command.set("player", "left", leftCallback, "hold")
    command.set("player", "right", rightCallback, "hold")
  end)

  it("should map the entity to the commands", function ()
    assert.are.same({
      left = leftCallback,
      right = rightCallback
    }, hid.commands.hold.player)
  end)

  it("should create an input set", function ()
    assert.are.same({
      left = false,
      right = false
    }, components.controllable[playerId].hold)
  end)
end)
