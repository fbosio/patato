local animator, entityTagger, entityResources, playerId, dt

before_each(function ()
  animator = require "engine.systems.animator"
  entityTagger = require "engine.tagger"

  animator.load(entityTagger)
  entityResources = {
    player = {
      animations = {
        standing = {
          {sprite = 1, duration = 5},
          {sprite = 2, duration = 8},
          {sprite = 3, duration = 10}
        }
      }
    }
  }
  playerId = entityTagger.tag("player")
  dt = 2
end)

after_each(function ()
  package.loaded["engine.systems.animator"] = nil
  package.loaded["engine.tagger"] = nil
end)

describe("updating an animation with several frames", function ()
  local components

  before_each(function ()
    components = {
      animation = {
        [playerId] = {
          name = "standing",
          frame = 1,
          time = 4
        }
      }
    }

    animator.update(dt, components, entityResources)
  end)

  it("should advance a frame", function ()
    assert.are.same(2, components.animation[playerId].frame)
  end)

  it("should decrease the elapsed time", function ()
    assert.are.same(1, components.animation[playerId].time)
  end)
end)

describe("playing an animation until its end", function ()
  it("should go back to its first frame", function ()
    local components = {
      animation = {
        [playerId] = {
          name = "standing",
          frame = 3,
          time = 8
        }
      }
    }

    animator.update(dt, components, entityResources)

    assert.are.same(1, components.animation[playerId].frame)
  end)
end)
