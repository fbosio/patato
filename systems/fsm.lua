local M = {}


function M.finiteStateMachineRunner(componentsTable, dt)
  local finiteStateMachines = componentsTable.finiteStateMachines or {}
  for entity, finiteStateMachine in pairs(finiteStateMachines) do
    finiteStateMachine.stateTime = math.max(0,
                                            finiteStateMachine.stateTime - dt)
  end
end


return M
