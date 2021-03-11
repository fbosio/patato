local iter = require "engine.iterators"
local entityTagger = require "engine.tagger"
local M = {}

function M.update(components)
  for entity, isGarbage in iter.garbage(components) do
    if isGarbage then
      entityTagger.remove(entity)
      for _, component in pairs(components) do
        component[entity] = nil
      end
    end
  end
end

return M
