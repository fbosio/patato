local M = {}

function M.update(st)
  for entity, isGarbage in pairs(st.garbage or {}) do
    for _, component in pairs(st) do
      component[entity] = nil
    end
  end
end

return M
