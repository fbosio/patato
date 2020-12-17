local engine = require "engine"

function love.load()
  engine.load()
end

function love.update(dt)
  engine.update(dt)
end

function love.draw()
  engine.draw()
end

function love.keypressed(key)
  engine.keypressed(key)
end