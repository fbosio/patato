local engine = require "engine"
local elapsed, message, score


function love.load()
  engine.load()

  engine.setMenuOption("mainMenu", 1, function ()
    engine.startGame()  -- changeScene (call automatically if there is no menu)
  end)
  engine.setMenuOption("mainMenu", 2, function ()
    elapsed = 0
    message = "Hola, mundo"
  end)
  engine.setMenuOption("mainMenu", 3, function ()
    engine.startGame("secretLevel")
  end)

  engine.setAction("showCustomMessage", function ()
    message = "Flashlight!"
  end)
  engine.setOmissions({"showCustomMessage"}, function ()
    message = ""
  end)

  engine.setAction("walkLeft", function (c)
    c.velocity.x = -c.impulseSpeed.walk
    c.animation.name = "walking"
  end)
  engine.setAction("walkRight", function (c)
    c.velocity.x = c.impulseSpeed.walk
    c.animation.name = "walking"
  end)
  engine.setAction("walkUp", function (c)
    c.velocity.y = -c.impulseSpeed.walk
    c.animation.name = "walking"
  end)
  engine.setAction("walkDown", function (c)
    c.velocity.y = c.impulseSpeed.walk
    c.animation.name = "walking"
  end)
  engine.setOmissions({"walkLeft", "walkRight", "walkUp", "walkDown"},
    function (c)
      c.animation.name = "standing"
    end
  )

  score = 0
  engine.setCollectableEffect("bottle", function ()
    score = score + 1
  end)
end

function love.update(dt)
  engine.update(dt)

  if elapsed then
    elapsed = elapsed + dt
    if elapsed > 1 then
      elapsed = nil
      message = nil
    end
  end
end

function love.draw()
  engine.draw()

  if message then
    love.graphics.print(message, 0, 0)
  end

  if not engine.gameState.inMenu then
    love.graphics.print(score, 0, 0)
  end
end

function love.keypressed(key)
  engine.keypressed(key)
end