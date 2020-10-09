local fsm = require "components.fsm"


local M = {}

function M.load(name, state)
  local entitiesData = state.currentLevel.entitiesData or {}
  local player = entitiesData.player
  if player then
    state.positions = state.positions or {}
    state.positions[name] = {
      x = player[1][1],
      y = player[1][2]
    }
    state.velocities = state.velocities or {}
    state.velocities[name] = {x=0, y=0}
    state.finiteStateMachines = state.finiteStateMachines or {}
    state.finiteStateMachines[name] = fsm.FiniteStateMachine("idle")

    -- This might be removed when enemies are created
    local players = state.players or {}
    players[name] = players[name] or {}
    if players[name].control then
      state.living = {
        [name] = {health = 1}
      }
    end
    local speedImpulses = state.speedImpulses or {}
    speedImpulses[name] = speedImpulses[name] or {}
    speedImpulses[name].walk = speedImpulses[name].walk or 0
    speedImpulses[name].crouchWalk = speedImpulses[name].crouchWalk or 0
    speedImpulses[name].jump = speedImpulses[name].jump or 0
  end
end

return M
