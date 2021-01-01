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
  
  engine.setAction("jump", function (c)
    if c.velocity.y == 0 then
      c.velocity.y = -c.impulseSpeed.jump
    end
  end)
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

  engine.setInputs("patato", {
    walkLeft = {key = "left"},
    walkRight = {key = "right"},
    walkUp = {key = "up"},
    walkDown = {key = "down"},
    stopWalkingHorizontally = {keys = {"left", "right"}, release = true},
    stopWalkingVertically = {keys = {"up", "down"}, release = true},
    jump = {key = "jump", oneShot = true},
    showCustomMessage = {key = "message"},
    hideCustomMessage = {key = "message", release = true}
  })
  engine.setInputs("mainMenu", {
    menuPrevious = {key = "up", oneShot = true},
    menuNext = {key = "down", oneShot = true},
    menuSelect = {key = "start", oneShot = true}
  })

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
