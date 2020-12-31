local engine = require "engine"
local elapsed, message, score


function love.load()
  engine.load()

  engine.setMenuOptionEffect("mainMenu", 1, function ()
    engine.startGame()  -- changeScene (call automatically if there is no menu)
  end)
  engine.setMenuOptionEffect("mainMenu", 2, function ()
    elapsed = 0
    message = "Hola, mundo"
  end)
  engine.setMenuOptionEffect("mainMenu", 3, function ()
    engine.startGame("secretLevel")
  end)
  
  -- engine.setAction("jump", function (c)
  --   if c.velocity.y == 0 then
  --     c.velocity.y = -c.impulseSpeed.jump
  --   end
  -- end)
  engine.setAction("showCustomMessage", function ()
    message = "Flashlight!"
  end)
  engine.setAction("hideCustomMessage", function ()
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

  engine.setInput("patato", "walkLeft", engine.command{key = "left"})
  engine.setInput("patato", "walkRight", engine.command{key = "right"})
  engine.setInput("patato", "walkUp", engine.command{key = "up"})
  engine.setInput("patato", "walkDown", engine.command{key = "down"})
  engine.setInput("patato", "stopWalkingHorizontally",
                  engine.command{keys = {"left", "right"}, release = true})
  engine.setInput("patato", "stopWalkingVertically",
                  engine.command{keys = {"up", "down"}, release = true})
  -- engine.setInput("jump", engine.command{key = "jump"})
  -- engine.setInput("patato", "showCustomMessage",
  --                 engine.command{key = "message"})
  -- engine.setInput("patato", "hideCustomMessage",
  --                 engine.command{key = "message", release = true})
  engine.setInput("mainMenu", "menuPrevious",
                  engine.command{key = "up", oneShot = true})
  engine.setInput("mainMenu", "menuNext",
                  engine.command{key = "down", oneShot = true})
  engine.setInput("mainMenu", "menuSelect",
                  engine.command{key = "start", oneShot = true})

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

  local mouseX, mouseY = love.mouse.getPosition()
  love.graphics.print(tostring(mouseX) .. ", " .. tostring(mouseY),
                      mouseX + 10, mouseY - 10)
end

function love.keypressed(key)
  engine.keypressed(key)
end
