local M = {}


function M.stateMachineRunner(componentsTable, dt)
  local stateMachines = componentsTable.stateMachines or {}
  for entity, stateMachine in pairs(stateMachines) do
    stateMachine.stateTime = math.max(0, stateMachine.stateTime - dt)
  end
end


return M
