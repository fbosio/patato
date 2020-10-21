local components = require "components"


local M = {}


local function removeEntity(state, entity)
  state.positions[entity] = nil
  state.velocities[entity] = nil
  state.speedImpulses[entity] = nil
  state.collisionBoxes[entity] = nil
  state.living[entity] = nil
  state.spawned[entity] = nil
end


function M.collision(state)
  for attacker, animationClip in pairs(state.animationClips or {}) do
    local attackerPosition = state.positions[attacker]
    local currentAnimation =
      animationClip.animations[animationClip.currentAnimationName]
    local attackBox =
      currentAnimation.frames[animationClip:currentFrameNumber()].attackBox

    if attackBox ~= nil then
      local collisionBoxes = state.collisionBoxes or {}

      for attackee, collisionBox in pairs(collisionBoxes) do
        local attackeePosition = state.positions[attackee]
        if attackee ~= attacker then
          local translatedAttackBox = attackBox:translated(attackerPosition,
                                                           animationClip)
          local translatedCollisionBox =
            collisionBox:translated(attackeePosition)

          if translatedAttackBox:intersects(translatedCollisionBox) then
            removeEntity(state, attackee)
          end
        end
      end
    end
  end
end


return M
