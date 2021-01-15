local configLoader

before_each(function ()
  configLoader = require "engine.systems.loaders.config"
end)

after_each(function ()
  package.loaded["engine.systems.loaders.config"] = nil
end)

describe("loading a non existent config", function ()
  it("should return a config with a controllable player", function ()
    local config = false

    local loadedConfig = configLoader.load(config)
    
    assert.are.same({"controllable"}, loadedConfig.entities.player.flags)
  end)
end)

describe("loading a existent config", function ()
  it("should return the same config", function ()
    local config = {
      entities = {
        player = {
          flags = {
            "controllable",
            "collector",
            "solid",
            "gravitational",
            "climber"
          },
          collisionBox = {20, 120, 40, 120},
          impulseSpeed = {
            jump = 1500,
            climb = 200,
            climbJump = 700
          }
        }
      }
    }
    
    local loadedConfig = configLoader.load(config)

    assert.are.same(config, loadedConfig)
  end)
end)

describe("loading a config that is not a table", function ()
  it("should throw an error", function ()
    local absurdConfig = true

    assert.has_error(function () configLoader.load(absurdConfig) end)
  end)
end)