local engine = require "engine"
local patato = require "game.patato"
local menu = require "game.menu"
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
    menu.update(commands, engine.gameState.menu.mainMenu,
                engine.getComponents("mainMenu").menu)
  else
    patato.update(commands, engine.getComponents("patato"))
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
