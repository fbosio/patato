local musicalizer

before_each(function ()
  musicalizer = require "engine.systems.musicalizer"
end)

after_each(function ()
  package.loaded["engine.systems.musicalizer"] = nil
end)

describe("loading a jukebox pointing to a background music", function ()
  it("should play that music and stop the rest", function ()
    function newSource()
      local source = {}
      function source:play() end
      function source:isPlaying()
        return true
      end
      function source:stop() end
      return mock(source)
    end
    local world = {
      resources = {
        sounds = {
          bgm = {
            ["Take Five"] = newSource(),
            ["Brick House"] = newSource()
          }
        }
      },
      gameState = {
        components = {
          jukebox = {
            {bgm = "Brick House"}
          }
        }
      }
    }

    musicalizer.load(world)

    assert.stub(world.resources.sounds.bgm["Take Five"].stop).was.called(1)
    assert.stub(world.resources.sounds.bgm["Brick House"].play).was.called(1)
  end)
end)
