local components = require "components"
local animation = require "components.animation"


local M = {}


function M.animator(state, dt)
  for entity, animationClip in pairs(state.animationClips or {}) do
    local currentAnimation =
      animationClip.animations[animationClip.currentAnimationName]
    local currentAnimationDuration = currentAnimation:duration()

    if animationClip.currentTime >= currentAnimationDuration then
      if currentAnimation.looping then
        animationClip.currentTime = animationClip.currentTime
                                    - currentAnimationDuration
      else
        animationClip.currentTime = currentAnimationDuration - dt
        -- sacrilegious
        animationClip._done = true
      end
    else
      animationClip.currentTime = animationClip.currentTime + dt
    end
  end
end


function M.animationRenderer(state, spriteSheet, positions)
  components.assertDependency(state, "animationClips", "positions")

  for entity, animationClip in pairs(state.animationClips or {}) do
    local position = positions[entity]
    local scale = 0.5
    local currentAnimation =
      animationClip.animations[animationClip.currentAnimationName]
    local currentFrame =
      currentAnimation.frames[animationClip:currentFrameNumber()]
    local _, _, width, height = currentFrame.quad:getViewport()
    local directionFactor = animationClip.facingRight and 1 or -1
    local offsetX = (animationClip.facingRight and 1 or -1)
                    * currentFrame.origin.x

    local transform = love.math.newTransform(position.x, position.y)
    transform:translate(offsetX, currentFrame.origin.y)
    transform:scale(animation.scale * directionFactor, animation.scale)
    love.graphics.draw(spriteSheet, currentFrame.quad, transform)
  end
end

return M
