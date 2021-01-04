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

  engine.setAction("walkLeft", function (c)
    c.velocity.x = -c.impulseSpeed.walk
    c.animation.name = "walking"
  end)
  engine.setAction("walkRight", function (c)
    c.velocity.x = c.impulseSpeed.walk
    c.animation.name = "walking"
  end)
  engine.setAction("stopWalkingHorizontally", function (c)
    c.velocity.x = 0
    c.animation.name = "standing"
  end)
  engine.setAction("jump", function (c)
    if c.climber.climbing then
      c.climber.climbing = false
      c.velocity.y = -c.impulseSpeed.jump
      c.gravitational.enabled = true
    elseif c.velocity.y == 0 then
      c.velocity.y = -c.impulseSpeed.jump
    end
  end)
  engine.setAction("startClimb", function (c)
    c.climber.climbing = true
  end)
  engine.setAction("climbUp", function (c)
    if c.climber.climbing and c.climber.trellis then
      c.velocity.y = -c.impulseSpeed.climb
    end
  end)
  engine.setAction("climbDown", function (c)
    if c.climber.climbing and c.climber.trellis then
      c.velocity.y = c.impulseSpeed.climb
    end
  end)
  engine.setAction("stopClimbingVertically", function (c)
    if c.climber.climbing then
      c.velocity.y = 0
    end
  end)
  
  engine.setInputs("patato", {
    walkLeft = engine.command{key = "left"},
    walkRight = engine.command{key = "right"},
    startClimb = engine.command{keys = {"up", "down"}, oneShot = true},
    climbUp = engine.command{key = "up"},
    climbDown = engine.command{key = "down"},
    stopWalkingHorizontally = engine.command{
      keys = {"left", "right"},
      release = true
    },
    stopClimbingVertically = engine.command{
      keys = {"up", "down"},
      release = true
    },
    jump = engine.command{key = "jump", oneShot = true}
  })
  engine.setInputs("mainMenu", {
    menuPrevious = engine.command{key = "up", oneShot = true},
    menuNext = engine.command{key = "down", oneShot = true},
    menuSelect = engine.command{key = "start", oneShot = true}
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

function love.keyreleased(key)
  engine.keyreleased(key)
end
