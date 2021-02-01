local M = {}

function M.update(t)
  t.velocity.x = -t.impulseSpeed.fly
end

return M
