local camera, entityTaggerMock

before_each(function ()
  camera = require "engine.systems.messengers.camera"
  entityTaggerMock = {}
  function entityTaggerMock.getId(name)
    return name
  end
  camera.load({}, entityTaggerMock)
end)

after_each(function ()
  package.loaded["engine.systems.messengers.camera"] = nil
end)

describe("with a camera, its target", function ()
  local components, cameraData
  before_each(function ()
    components = {
      camera = {myCamera = true},
      position = {
        myCamera = {x = 0, y = 0},
        player = {x = 1528, y = 500}
      },
      collisionBox = {
        myCamera = {
          origin = {x = 0, y = 0},
          width = 800,
          height = 600
        },
        player = {
          origin = {x = 16, y = 64},
          width = 32,
          height = 64
        }
      }
    }
    cameraData = {
      target = "player",
      focusCallback = function (t)
        return t.position.x, t.position.y
      end
    }
  end)

  describe("and no limiter", function ()
    it("should follow the target", function ()
      camera.update(components, cameraData)

      assert.are.same({x = 1128, y = 200}, components.position.myCamera)
    end)
  end)
  
  describe("and a limiter,", function ()
    before_each(function ()
      components.limiter = {myLimiter = true}
      components.position.myLimiter = {x = 0, y = 0}
      components.collisionBox.myLimiter = {
        origin = {x = 0, y = 0},
        width = 1200,
        height = 1200
      }
    end)

    describe("placing the target inside the limiter", function ()
      it("should follow the target", function ()
        components.position.player = {x = 640, y = 480}

        camera.update(components, cameraData)

        assert.are.same({x = 240, y = 180}, components.position.myCamera)
      end)
    end)
  
    describe("placing the target outside the limiter", function ()
      before_each(function ()
        camera.update(components, cameraData)
      end)

      it("should try to follow the target", function ()
        assert.are.same(200, components.position.myCamera.y)
      end)
      
      it("should keep the camera inside the limiter", function ()
        assert.are.same(400, components.position.myCamera.x)
      end)
    end)
  end)

  describe("and a window", function ()
    before_each(function ()
      components.window = {cameraWindow = true}
      components.position.cameraWindow = {x = 500, y = 400}
      components.collisionBox.cameraWindow = {
        origin = {x = 160, y = 120},
        width = 320,
        height = 240
      }
    end)

    describe("placing the target inside the window", function ()
      it("should not make the window follow the player", function ()
        components.position.player.x = 580
        components.position.player.y = 420

        camera.update(components, cameraData)

        assert.are.same({x = 500, y = 400}, components.position.cameraWindow)
      end)
    end)

    describe("placing the target outside the window", function ()
      before_each(function ()
        components.position.player.x = 670
        components.position.player.y = 420
  
        camera.update(components, cameraData)
      end)

      it("should make the window follow the player", function ()
        assert.are.same({x = 526, y = 400}, components.position.cameraWindow)
      end)

      it("should follow the window", function ()
        assert.are.same({x = 126, y = 100}, components.position.myCamera)
      end)
    end)
  end)
end)
