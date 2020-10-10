local M = {}


function M.staminaSupply(state, dt)
  for entity, living in pairs(state.living or {}) do
    local stamina = living.stamina
    if stamina and stamina > 0 and stamina < 100 then
      stamina = math.min(100, stamina + dt * 25)
    end
  end
end


return M
