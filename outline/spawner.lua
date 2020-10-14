local box = require "components.box"


local spawnKey = "i"
local holdingKey = false
local beeFlightSpeed = 1000
local spawnCount = 0


local M = {direction=1, x=0, y=0}


function spawnBee(state, cameraEntity)
  state.positions = state.positions or {}
  translation = state.positions[cameraEntity] or {x=0, y=0}

  local n = love.math.random(0, 1)
  direction = 1 - 2*n
  x = n * love.graphics.getWidth() + translation.x
  y = love.math.random(0, love.graphics.getHeight()) - translation.y

  local entity = "bee" .. spawnCount;
  state.positions[entity] = {
    x = x,
    y = y
  }
  state.velocities = state.velocities or {}
  state.velocities[entity] = {
    x = direction * beeFlightSpeed,
    y = 0
  }
  local speedImpulse = (state.speedImpulses or {})[entity] or {}
  speedImpulse.flightSpeed = beeFlightSpeed
  state.collisionBoxes = state.collisionBoxes or {}
  state.collisionBoxes[entity] = box.CollisionBox:new{width=20, height=20}

  spawnCount = spawnCount + 1

  M.direction = direction
  M.x = x
  M.y = y
end


function M.update(state, cameraEntity)
  if love.keyboard.isDown(spawnKey) and not holdingKey then
    holdingKey = true
    spawnBee(state, cameraEntity)
  elseif not love.keyboard.isDown(spawnKey) then
    holdingKey = false
  end
end


return M
