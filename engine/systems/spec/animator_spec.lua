local animator, entityTagger

before_each(function ()
  animator = require "engine.systems.animator"
  entityTagger = require "engine.tagger"

  animator.load(entityTagger)
end)

after_each(function ()
  package.loaded["engine.systems.animator"] = nil
  package.loaded["engine.tagger"] = nil
end)

describe("updating an animation with several frames", function ()
  local entityResources, playerId, components, dt

  before_each(function ()
    entityResources = {
      player = {
        animations = {
          standing = {
            frames = {1, 2, 3},
            durations = {5, 8, 10},
            looping = false
          }
        }
      }
    }
    playerId = entityTagger.tag("player")
    components = {
      animation = {
        [playerId] = {
          name = "standing",
          frame = 1,
          time = 4,
          ended = false
        }
      }
    }
    dt = 2

    animator.update(dt, components, entityResources)
  end)

  it("should advance a frame", function ()
    assert.are.same(2, components.animation[playerId].frame)
  end)

  it("should decrease the elapsed time", function ()
    assert.are.same(1, components.animation[playerId].time)
  end)
end)

describe("playing a looping animation until its end", function ()
  it("should go back to its first frame", function ()
    local entityResources = {
      player = {
        animations = {
          standing = {
            frames = {1, 2, 3},
            durations = {5, 8, 10},
            looping = true
          }
        }
      }
    }
    local playerId = entityTagger.tag("player")
    local components = {
      animation = {
        [playerId] = {
          name = "standing",
          frame = 3,
          time = 8,
          ended = false
        }
      }
    }
    local dt = 2

    animator.update(dt, components, entityResources)

    assert.are.same(1, components.animation[playerId].frame)
  end)
end)

describe("playing a nonlooping animation until its end", function ()
  it("should stop the animation", function ()
    local entityResources = {
      player = {
        animations = {
          standing = {
            frames = {1, 2, 3},
            durations = {5, 8, 10},
            looping = false
          }
        }
      }
    }
    local playerId = entityTagger.tag("player")
    local components = {
      animation = {
        [playerId] = {
          name = "standing",
          frame = 3,
          time = 8,
          ended = false
        }
      }
    }
    local dt = 2

    animator.update(dt, components, entityResources)

    assert.are.same(3, components.animation[playerId].frame)
    assert.is.truthy(components.animation[playerId].ended)
  end)
end)