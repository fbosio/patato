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
  local animationResources, playerId, animationComponents, dt

  before_each(function ()
    animationResources = {
      player = {
        standing = {
          frames = {1, 2, 3},
          durations = {5, 8, 10},
          looping = false
        }
      }
    }
    playerId = entityTagger.tag("player")
    animationComponents = {
      [playerId] = {
        name = "standing",
        frame = 1,
        time = 4,
        ended = false
      }
    }
    dt = 2
    animator.update(dt, animationComponents, animationResources)
  end)

  it("should advance a frame", function ()
    assert.are.same(2, animationComponents[playerId].frame)
  end)

  it("should decrease the elapsed time", function ()
    assert.are.same(1, animationComponents[playerId].time)
  end)
end)

-- describe("playing a looping animation until its end", function ()
--   it("should go back to its first frame", function ()
    
--   end)
-- end)

-- describe("playing a nonlooping animation until its end", function ()
--   it("should stop the animation", function ()
    
--   end)
-- end)