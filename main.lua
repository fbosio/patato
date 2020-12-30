local engine = require "engine"
local score


function love.load()
  engine.load()

  score = 0
  -- setCollectableEffect(name, callback)
  engine.setCollectableEffect("coin", function ()
    score = score + 1
  end)
end

function love.update(dt)
  engine.update(dt)
end

function love.draw()
  engine.draw()

  love.graphics.print(score, 0, 0)
end