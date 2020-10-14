local box = require "components.box"
local outline = require "outline"


local M = {}


local function getCameraPosition(state)
  local position = {x=0, y=0}

  for entity, isCamera in pairs(state.cameras or {}) do
    if isCamera then
      position = state.positions[entity]
      break  -- get only the first camera entity
    end
  end

  return position
end


local beeEntityPrefix = "bee"
local spawnCount = 0
local beeFlightSpeed = 1000

local function spawnBee(state)
  spawnCount = spawnCount + 1
  local entity = beeEntityPrefix .. spawnCount;
  state.positions = state.positions or {}
  local cameraPosition = getCameraPosition(state)
  local n = love.math.random(0, 1)
  state.positions[entity] = {
    x = n*love.graphics.getWidth() + cameraPosition.x,
    y = love.math.random(0, love.graphics.getHeight()) - cameraPosition.y
  }
  state.velocities = state.velocities or {}
  local direction = 1 - 2*n
  state.velocities[entity] = {
    x = direction * beeFlightSpeed,
    y = 0
  }
  local speedImpulse = (state.speedImpulses or {})[entity] or {}
  speedImpulse.flightSpeed = beeFlightSpeed
  state.collisionBoxes = state.collisionBoxes or {}
  state.collisionBoxes[entity] = box.CollisionBox:new{width=20, height=20}

  state.spawned = state.spawned or {}
  state.spawned[entity] = true
end


local function destroyBees(state)
  for entity, isSpawn in pairs(state.spawned or {}) do
    if isSpawn then
      state.positions = state.positions or {}
      local position = state.positions[entity]
      local cameraPosition = getCameraPosition(state)
      if position and (position.x < cameraPosition.x
                       or position.x > cameraPosition.x
                                       + love.graphics.getWidth()) then
        state.positions[entity] = nil
        state.velocities[entity] = nil
        state.speedImpulses[entity] = nil
        state.collisionBoxes[entity] = nil
        state.spawned[entity] = nil
      end
    end  -- if isSpawn
  end  -- for
end


local spawnKey = "i"
local holdingKey = false

function M.update(state)
  if love.keyboard.isDown(spawnKey) and not holdingKey then
    holdingKey = true
    spawnBee(state)
  elseif not love.keyboard.isDown(spawnKey) then
    holdingKey = false
  end

  destroyBees(state)
end


return M
