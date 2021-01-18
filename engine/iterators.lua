local M = {}

local function velocityIterator(t, k)
  local v
  k, v = next(t.velocity, k)
  if k then return k, v, t.position[k] end
end

function M.velocity(components)
  return velocityIterator, components, nil
end

return M