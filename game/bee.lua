local M = {}

function M.update(t, patatoEntity)
  t.velocity.x = -t.impulseSpeed.fly

  if t.flap.overlap == patatoEntity then
    t.garbage = true
  end
end

return M
