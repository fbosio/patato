local M = {}


function M.StateMachine(currentState)
  local newComponent = {
    currentState = currentState,
    stateTime = 0
  }

  function newComponent:setState(newState, time)
    self.currentState = newState
    self.stateTime = time or 0
  end

  return newComponent
end


return M
