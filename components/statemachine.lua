local M = {}


M.StateMachine = {
  currentState = nil,
  stateTime = 0
}

function M.StateMachine:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  return o
end

function M.StateMachine:setState(newState, time)
  self.currentState = newState
  self.stateTime = time or 0
end


return M
