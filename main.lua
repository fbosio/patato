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
    elapsed = 0
    message = "Flashlight!"
  end)

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

  if not engine.inMenu then
    love.graphics.print(score, 0, 0)
  end
end

function love.keypressed(key)
  engine.keypressed(key)
end