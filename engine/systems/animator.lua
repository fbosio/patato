local iter = require "engine.iterators"
local M = {}

function M.load(entityTagger)
  M.entityTagger = entityTagger
end

function M.update(dt, components, entityResources)
  for entity, animation in iter.animation(components) do
    local entityName = M.entityTagger.getName(entity)
    local resource = entityResources[entityName].animations[animation.name]
    animation.time = animation.time + dt
    local remainingTime = animation.time - resource[animation.frame].duration
    if remainingTime >= 0 then
      animation.time = remainingTime
      if animation.frame == #resource then
        animation.frame = 1
      else
        animation.frame = animation.frame + 1
      end
    end
  end
end

return M
