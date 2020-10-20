local box = require "components.box"


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
  local playerPosition = state.positions.patato
  local playerCollisionBox = state.collisionBoxes.patato
  local n = love.math.random(0, 1)
  state.positions[entity] = {
    x = n*love.graphics.getWidth() + cameraPosition.x,
    y = playerPosition.y - playerCollisionBox.height - cameraPosition.y
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
  local living = state.living or {}
  living[entity] = {health=1}

  state.spawned = state.spawned or {}
  state.spawned[entity] = true
end


local function attackPlayers(state)
  for spawnEntity, isSpawn in pairs(state.spawned or {}) do
    if isSpawn then
      local positions = state.positions or {}
      local collisionBoxes = state.collisionBoxes or {}

      local spawnPosition = positions[spawnEntity]
      local spawnBox = collisionBoxes[spawnEntity]
      if spawnBox then
        local referenceSpawnBox = spawnBox:translated(spawnPosition)
        for playerEntity, player in pairs(state.players or {}) do
          local isPlayerAlive = ((state.living or {})[playerEntity] or {}).health > 0
          local stateMachine = (state.stateMachines or {})[playerEntity] or {}
          local playerPosition = positions[playerEntity]
          local playerBox = collisionBoxes[playerEntity]
          local referencePlayerBox = playerBox:translated(playerPosition)
          if isPlayerAlive and stateMachine.currentState ~= "hurt"
              and referenceSpawnBox:intersects(referencePlayerBox) then
            stateMachine:setState("hurt")
            break
          end
        end
      end

    end
  end
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

  attackPlayers(state)
  destroyBees(state)
end


return M
