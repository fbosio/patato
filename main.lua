local engine = require "engine"
local elapsed, message, score

love.run = engine.run

function love.load()
  engine.gameState.menu.mainMenu = {
    function ()
      engine.startGame()
    end,
    function ()
      elapsed = 0
      message = "Hola, mundo"
    end,
    function ()
      engine.startGame("secretLevel")
    end
  }

  engine.setCommand("patato", "left", function (t)
    t.velocity.x = -t.impulseSpeed.walk
    t.animation.name = "walking"
  end, "hold")
  engine.setCommand("patato", "right", function (t)
    t.velocity.x = t.impulseSpeed.walk
    t.animation.name = "walking"
  end, "hold")
  engine.setCommand("patato", "left", function (t)
    t.velocity.x = 0
    t.animation.name = "standing"
  end, "release")
  engine.setCommand("patato", "right", function (t)
    t.velocity.x = 0
    t.animation.name = "standing"
  end, "release")
  engine.setCommand("patato", "jump", function (t)
    if t.climber.climbing then
      t.climber.climbing = false
      t.gravitational.enabled = true
    end
    if t.climber.climbing or t.velocity.y == 0 then
      t.animation.name = "jumping"
      t.velocity.y = -t.impulseSpeed.jump
    end
  end, "press")
  engine.setCommand("patato", "up", function (t)
    t.climber.climbing = true
    t.animation.name = "climbingIdle"
  end, "press")
  engine.setCommand("patato", "down", function (t)
    t.climber.climbing = true
    t.animation.name = "climbingIdle"
  end, "press")
  engine.setCommand("patato", "up", function (t)
    if t.climber.climbing and t.climber.trellis then
      t.velocity.y = -t.impulseSpeed.climb
      t.animation.name = "climbingMove"
    end
  end, "hold")
  engine.setCommand("patato", "down", function (t)
    if t.climber.climbing and t.climber.trellis then
      t.velocity.y = t.impulseSpeed.climb
      t.animation.name = "climbingMove"
    end
  end, "hold")
  engine.setCommand("patato", "up", function (t)
    if t.climber.climbing then
      t.velocity.y = 0
      t.animation.name = "climbingIdle"
    end
  end, "release")
  engine.setCommand("patato", "down", function (t)
    if t.climber.climbing then
      t.velocity.y = 0
      t.animation.name = "climbingIdle"
    end
  end, "release")

  engine.setCommand("mainMenu", "up", function (t)
    t.menu.selected = t.menu.selected - 1
    if t.menu.selected == 0 then
      t.menu.selected = #t.menu.options
    end
  end, "press")
  engine.setCommand("mainMenu", "down", function (t)
    t.menu.selected = t.menu.selected + 1
    if t.menu.selected == #t.menu.options + 1 then
      t.menu.selected = 1
    end
  end, "press")
  engine.setCommand("mainMenu", "start", function (t)
    engine.gameState.menu.mainMenu[t.menu.selected]()
  end, "press")
  
  score = 0
  engine.gameState.collectableEffects.bottles = function ()
    score = score + 1
    local pitch = 1 + (2*love.math.random()-1) / 36
    local sfx = engine.resources.sounds.sfx.collected
    sfx:setPitch(pitch)
    sfx:play()
  end
  
  engine.gameState.camera.target = "patato"
  engine.gameState.camera.focus = function (t)
    return t.position.x, t.position.y - t.collisionBox.height / 2
  end
end

function love.update(dt)  
  if elapsed then
    elapsed = elapsed + dt
    if elapsed > 1 then
      elapsed = nil
      message = nil
    end
  end
end

function love.draw()
  if message then
    love.graphics.print(message, 0, 0)
  end

  if not engine.gameState.inMenu then
    love.graphics.print(score, 0, 0)
  end
end
