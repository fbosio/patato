local statemachine = require "components.statemachine"

local sprites = {}
pcall(function()
  sprites = require "resources.sprites"
end)


local M = {}


local function loadPositions(name, state)
  state.positions = state.positions or {}
  state.positions[name] = {
    x = player[1][1],
    y = player[1][2]
  }
end


local function loadVelocities(name, state)
  state.velocities = state.velocities or {}
  state.velocities[name] = {x=0, y=0}
end


local function loadStateMachines(name, state)
  state.stateMachines = state.stateMachines or {}
  state.stateMachines[name] = statemachine.StateMachine:new{
    currentState = "idle"
  }
end


local function loadSpeedImpulses(name, state)
  local speedImpulses = state.speedImpulses or {}
  speedImpulses[name] = speedImpulses[name] or {}
  speedImpulses[name].walk = speedImpulses[name].walk or 0
  speedImpulses[name].crouchWalk = speedImpulses[name].crouchWalk or 0
  speedImpulses[name].jump = speedImpulses[name].jump or 0
  speedImpulses[name].climb = speedImpulses[name].climb or 0
end


function M.load(name, state)
  local entitiesData = state.currentLevel.entitiesData or {}
  local player = entitiesData.player
  if player then
    loadPositions(name, state)
    loadVelocities(name, state)
    loadStateMachines(name, state)

    -- This might be removed when enemies are created
    local players = state.players or {}
    players[name] = players[name] or {}
    if players[name].control then
      state.living = {
        [name] = {health = 1}
      }
    end

    loadSpeedImpulses(name, state)    
  end
end

return M
