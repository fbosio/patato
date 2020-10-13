local components = require "components"


local M = {}


function M.collision(state)
	-- components.assertDependency(state, "animationClips", "positions")

  for attacker, animationClip in pairs(state.animationClips or {}) do
    local attackerPosition = state.positions[attacker]
    -- components.assertExistence(attacker, "animationClip",
    --                            {attackerPosition, "position"})
    local currentAnimation =
      animationClip.animations[animationClip.currentAnimationName]
    local attackBox =
      currentAnimation.frames[animationClip:currentFrameNumber()].attackBox

    if attackBox ~= nil then
      -- components.assertDependency(state, "collisionBoxes",
      --                             "positions")
      local collisionBoxes = state.collisionBoxes or {}

      for attackee, collisionBox in pairs(collisionBoxes) do
        local attackeePosition = state.positions[attackee]
        -- components.assertExistence(attackee, "collisionBox",
        --                            {attackeePosition, "position"})
        if attackee ~= attacker then
          local translatedAttackBox = attackBox:translated(attackerPosition,
                                                           animationClip)
          local translatedCollisionBox =
            collisionBox:translated(attackeePosition)

          if translatedAttackBox:intersects(translatedCollisionBox) then
            local direction = attackerPosition.x <= attackeePosition.x and 1
                              or -1
            state.velocities[attackee].x = 100 * direction
          end
        end
      end
    end
  end
end


return M
