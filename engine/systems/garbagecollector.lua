local iter = require "engine.iterators"
local M = {}

function M.update(components)
  for entity, isGarbage in iter.garbage(components) do
    if isGarbage then
      for _, component in pairs(components) do
        component[entity] = nil
      end
    end
  end
end

return M
