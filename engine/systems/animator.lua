local iter = require "engine.iterators"
local M = {}

function M.load(entityTagger)
  M.entityTagger = entityTagger
end

function M.update(dt, components, resources)
  for entity, animation in iter.animation(components) do
    if animation.enabled then
      local entityName = M.entityTagger.getName(entity)
      local resource =
        resources.entities[entityName].animations[animation.name]
      animation.time = animation.time + dt
      local remainingTime =
        animation.time - resource[animation.frame].duration
      if remainingTime >= 0 then
        animation.time = remainingTime
        if animation.frame == #resource then
          animation.frame = 1
        else
          animation.frame = animation.frame + 1
        end
        local sfxName = resource[animation.frame].sfx
        if sfxName then
          resources.sounds.sfx[sfxName]:stop()
          resources.sounds.sfx[sfxName]:play()
        end
      end
    end
  end
end

return M
