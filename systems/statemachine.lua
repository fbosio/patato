local M = {}


function M.stateMachineRunner(state, dt)
  local stateMachines = state.stateMachines or {}
  for entity, stateMachine in pairs(stateMachines) do
    stateMachine.stateTime = math.max(0, stateMachine.stateTime - dt)
  end
end


return M
