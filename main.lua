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
  local commands = engine.gameState.hid.commands

  if engine.gameState.inMenu then
    local menu = engine.getComponents("mainMenu").menu
    if commands.press.up then
      menu.selected = menu.selected - 1
      if menu.selected == 0 then
        menu.selected = #menu.options
      end
    end
    if commands.press.down then
      menu.selected = menu.selected + 1
      if menu.selected == #menu.options + 1 then
        menu.selected = 1
      end
    end
    if commands.press.start then
      engine.gameState.menu.mainMenu[menu.selected]()
    end
  else
    local patato = engine.getComponents("patato")
    if commands.hold.left and not commands.hold.right then
      patato.velocity.x = -patato.impulseSpeed.walk
      patato.animation.name = "walking"
    elseif commands.hold.right and not commands.hold.left then
      patato.velocity.x = patato.impulseSpeed.walk
      patato.animation.name = "walking"
    else
      patato.velocity.x = 0
      patato.animation.name = "standing"
    end
    if commands.press.jump then
      if patato.climber.climbing then
        patato.climber.climbing = false
        patato.gravitational.enabled = true
      end
      if patato.climber.climbing or patato.velocity.y == 0 then
        patato.animation.name = "jumping"
        patato.velocity.y = -patato.impulseSpeed.jump
      end
    end
    if (commands.press.up or commands.press.down)
        and not patato.climber.climbing then
      patato.climber.climbing = true
      patato.animation.name = "climbingIdle"
    end
    if patato.climber.climbing and patato.climber.trellis then
      if commands.hold.up and not commands.hold.down then
        patato.velocity.y = -patato.impulseSpeed.climb
        patato.animation.name = "climbingMove"
      elseif commands.hold.down and not commands.hold.up then
        patato.velocity.y = patato.impulseSpeed.climb
        patato.animation.name = "climbingMove"
      else
        patato.velocity.y = 0
        patato.animation.name = "climbingIdle"
      end
    end
  end
  
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
