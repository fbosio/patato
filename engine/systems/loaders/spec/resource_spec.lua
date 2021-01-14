local resources, loveMock, _

before_each(function ()
  resources = require "engine.systems.loaders.resources"
  local match = require "luassert.match"
  _ = match._

  local love = {graphics = {}}
  function love.graphics.getWidth()
    return 800
  end
  function love.graphics.getHeight()
    return 600
  end
  function love.graphics.getDimensions()
    return love.graphics.getWidth(), love.graphics.getHeight()
  end
  function love.graphics.newImage()
    return {
      getDimensions = function () return nil end,
      setWrap = function () end
    }
  end
  function love.graphics.newQuad()
  end
  loveMock = mock(love)
end)

after_each(function ()
  package.loaded["engine.systems.loaders.resources"] = nil
end)

describe("loading an entity with a path as a sprite image", function ()
  local spriteSheetPath, config, loadedResources

  before_each(function ()
    spriteSheetPath = "path/to/mySpriteSheet.png"
    config = {
      entities = {
        player = {
          resources = {
            sprites = {
              image = spriteSheetPath
            }
          }
        }
      }
    }

    loadedResources = resources.load(loveMock, config)
  end)

  it("should create a new image", function ()
    assert.stub(loveMock.graphics.newImage).was.called_with(spriteSheetPath)
  end)

  it("should load a default sprite scale", function ()
    assert.are.same(1, loadedResources.player.sprites.scale)
  end)

  it("should load a default sprite depth", function ()
    assert.are.same(1, loadedResources.player.sprites.depth)
  end)
end)

describe("loading an entity with an image and some quads", function ()
  local spriteSheetPath, config, loadedResources

  before_each(function ()
    spriteSheetPath = "path/to/mySpriteSheet.png"
    config = {
      entities = {
        player = {
          resources = {
            sprites = {
              image = spriteSheetPath,
              quads = {
                {1, 1, 32, 32, 16, 32},
                {33, 1, 32, 32, 0, 0},
                {1, 33, 32, 32, 16, 16}
              }
            }
          }
        }
      }
    }
    loadedResources = resources.load(loveMock, config)
  end)

  it("should create the defined number of quads", function ()
    local numberQuads = #config.entities.player.resources.sprites.quads
    assert.stub(loveMock.graphics.newQuad).was.called(numberQuads)
  end)

  it("should create the sprites with their defined origins", function ()
    local playerSpriteOrigins = loadedResources.player.sprites.origins
    assert.are.same({x = 16, y = 32}, playerSpriteOrigins[1])
    assert.are.same({x = 0, y = 0}, playerSpriteOrigins[2])
    assert.are.same({x = 16, y = 16}, playerSpriteOrigins[3])
  end)
end)

describe("loading an entity with a tiled image", function ()
  it("should create a quad with window dimensions", function ()
    local config = {
      entities = {
        player = {
          resources = {
            sprites = {
              image = "path/to/mySpriteSheet.png",
              tiled = true
            }
          }
        }
      }
    }
    
    resources.load(loveMock, config)

    local windowWidth, windowHeight = 800, 600
    assert.stub(loveMock.graphics.newQuad).was.called(1)
    assert.stub(loveMock.graphics.newQuad).was.called_with(0, 0, windowWidth,
                                                           windowHeight, _)
  end)
end)

describe("loading a tiled entity with quads", function ()
  it("should create a quad with window dimensions", function ()
    local config = {
      entities = {
        player = {
          resources = {
            sprites = {
              image = "path/to/mySpriteSheet.png",
              quads = {
                {32, 64, 64, 128, 16, 16}
              },
              tiled = true
            }
          }
        }
      }
    }
    
    resources.load(loveMock, config)

    local windowWidth, windowHeight = 800, 600
    assert.stub(loveMock.graphics.newQuad).was.called(1)
    assert.stub(loveMock.graphics.newQuad).was.called_with(0, 0, windowWidth,
                                                           windowHeight, _)
  end)
end)

describe("loading an entity with an image and depth", function ()
  it("should copy the depth attribute", function ()
    local config = {
      entities = {
        player = {
          resources = {
            sprites = {
              image = "path/to/mySpriteSheet.png",
              quads = {
                {32, 64, 64, 128, 16, 16}
              },
              depth = 0
            }
          }
        }
      }
    }
    
    local loadedResources = resources.load(loveMock, config)

    assert.are.same(0, loadedResources.player.sprites.depth)
  end)
end)

describe("loading sprites and an entity with animations", function ()
  local config, loadedResources

  before_each(function ()
    config = {
      entities = {
        player = {
          resources = {
            sprites = {
              image = "path/to/mySpriteSheet.png",
              quads = {
                {1, 1, 32, 32, 16, 32},
                {33, 1, 32, 32, 0, 0},
                {1, 33, 32, 32, 16, 16}
              },
            },
            animations = {
              standing = {1, 1},
              walking = {2, 0.5, 3, 0.5, 4, 0.5, 3, 0.5, true}
            }
          }
        }
      }
    }

    loadedResources = resources.load(loveMock, config)
  end)

  it ("should create an animations table for that entity", function ()
    local animations = loadedResources.player.animations
    local standingAnimation = animations.standing
    assert.are.same({1}, standingAnimation.frames)
    assert.are.same({1}, standingAnimation.durations)
    assert.is.falsy(standingAnimation.looping)

    local walkingAnimation = animations.walking
    assert.are.same({2, 3, 4, 3}, walkingAnimation.frames)
    assert.are.same({0.5, 0.5, 0.5, 0.5}, walkingAnimation.durations)
    assert.is.truthy(walkingAnimation.looping)
  end)
end)

describe("loading entities with animations with the same name", function ()
  it("should load the animations separately", function ()
    local spriteSheetPath = "path/to/mySpriteSheet.png"
    local config = {
      entities = {
        coin = {
          resources = {
            sprites = {
              image = spriteSheetPath,
              quads = {
                {1, 1, 32, 32, 16, 32},
              }
            },
            animations = {
              idle = {1, 1}
            }
          }
        },
        bottle = {
          resources = {
            sprites = {
              image = spriteSheetPath,
              quads = {
                {33, 1, 32, 32, 0, 0}
              }
            },
            animations = {
              idle = {1, 1}
            }
          }
        }
      }
    }

    local loadedResources = resources.load(loveMock, config)

    assert.is.truthy(loadedResources.coin.animations.idle)
    assert.is.truthy(loadedResources.bottle.animations.idle)
  end)
end)

describe("loading config with sprite scale", function ()
  it("should store it in resources table", function ()
    local config = {
      entities = {
        player = {
          resources = {
            sprites = {
              image = "path/to/mySpriteSheet.png",
              scale = 0.5
            }
          }
        }
      }
    }

    local loadedResources = resources.load(loveMock, config)

    assert.are.same(0.5, loadedResources.player.sprites.scale)
  end)
end)
