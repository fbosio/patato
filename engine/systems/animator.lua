local M = {}

function M.load(entityTagger)
  M.entityTagger = entityTagger
end

function M.update(dt, animationComponents, resources)
  for entity, animation in pairs(animationComponents or {}) do
    local entityName = M.entityTagger.getName(entity)
    local resource = resources[entityName].animations[animation.name]
    animation.time = animation.time + dt
    local remainingTime = animation.time - resource.durations[animation.frame]
    if remainingTime >= 0 then
      animation.time = remainingTime
      if animation.frame == #resource.frames then
        if resource.looping then
          animation.frame = 1
        else
          animation.ended = true
        end
      else
        animation.frame = animation.frame + 1
      end
    end
  end
end

return M
