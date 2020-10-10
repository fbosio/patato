local components = require "components"
local animation = require "components.animation"
local M = {}


local holdingJumpKey

local statesLogic = {
  idle = function (args)
    -- X Movement Input
      if love.keyboard.isDown("a") and not love.keyboard.isDown("d") then
        args.velocity.x = -args.speedImpulses.walk
        args.animationClip.facingRight = false

        if args.velocity.y == 0 then
          args.animationClip:setAnimation("walking")
        end
      elseif not love.keyboard.isDown("a") and love.keyboard.isDown("d") then
        args.velocity.x = args.speedImpulses.walk
        args.animationClip.facingRight = true

        if args.velocity.y == 0 then
          args.animationClip:setAnimation("walking")
        end
      elseif args.velocity.y == 0 then
        args.velocity.x = 0
        args.animationClip:setAnimation("standing")
      end

      if args.velocity.y ~= 0 then
        args.animationClip:setAnimation("jumping")
      end

      -- Y Movement Input
      if love.keyboard.isDown("k") and args.velocity.y == 0 and not holdingJumpKey then
        args.finiteStateMachine:setState("startingJump")
        args.animationClip:setAnimation("startingJump")
        holdingJumpKey = true
      elseif not love.keyboard.isDown("k") and holdingJumpKey then
        holdingJumpKey = false
      end

      if love.keyboard.isDown("j") then
        args.finiteStateMachine:setState("hurt")
      end

      if not love.keyboard.isDown("k") and love.keyboard.isDown("s")
          and args.velocity.y == 0 then
        args.finiteStateMachine:setState("crouching")
      end

      if love.keyboard.isDown("l") then
        args.velocity.x = 0
        args.finiteStateMachine:setState("punching")
        args.animationClip:setAnimation("punching")
      end
  end,

  startingJump = function (args)
    if args.animationClip:done() then
      args.finiteStateMachine:setState("idle")
      args.animationClip:setAnimation("jumping")
      args.velocity.y = -args.speedImpulses.jump
    end
  end,

  hurt = function (args)
    args.living.health = args.living.health - 1
    args.living.stamina = args.living.stamina and math.max(0, args.living.stamina - 25)
    if args.state.collisionBoxes[args.entity].hurtFallHeight then
      args.living.health = 0
      args.velocity.x = 0
      args.finiteStateMachine:setState("lyingDown", 1.5)
      args.animationClip:setAnimation("lyingDown")
    elseif args.living.health == 0 or (args.living.stamina and args.living.stamina == 0) then
      args.finiteStateMachine:setState("flyingHurt")
      local collectors = args.state.collectors or {}
      collectors[args.entity] = false
      args.animationClip:setAnimation("flyingHurt")
      args.velocity.x = (args.animationClip.facingRight and -1 or 1) * args.speedImpulses.walk
      args.velocity.y = -args.speedImpulses.jump
    else
      args.finiteStateMachine:setState("hit", 0.5)
      args.animationClip:setAnimation("hitByHighPunch")
    end
  end,

  hit = function (args)
    --velocity.x must be set to a property value from another component
    args.velocity.x = (args.animationClip.facingRight and -1 or 1) * args.speedImpulses.walk / 3
    if args.animationClip:done() then
      args.finiteStateMachine:setState("idle")
    end
  end,

  flyingHurt = function (args)
    if args.velocity.y == 0 then
      args.velocity.x = 0
      args.finiteStateMachine:setState("lyingDown", 1)
      args.animationClip:setAnimation("lyingDown")
    elseif args.velocity.y > 5000 then
      love.load()
    end
  end,

  lyingDown = function (args)
    if args.finiteStateMachine.stateTime == 0 then
      if args.living.health == 0 then
        love.load()
      else
        args.finiteStateMachine:setState("gettingUp")
        args.animationClip:setAnimation("gettingUp")
        args.living.stamina = args.living.stamina and 100
        local collectors = args.state.collectors or {}
        collectors[args.entity] = true
      end
    end
  end,

  gettingUp = function (args)
    if args.animationClip:done() then
      args.finiteStateMachine:setState("idle")
    end
  end,

  crouching = function (args)
    if love.keyboard.isDown("a") and not love.keyboard.isDown("d") then
      args.velocity.x = -args.speedImpulses.crouchWalk
      args.animationClip.facingRight = false
      args.animationClip:setAnimation("crouchWalking")
    elseif not love.keyboard.isDown("a") and love.keyboard.isDown("d") then
      args.velocity.x = args.speedImpulses.crouchWalk
      args.animationClip.facingRight = true
      args.animationClip:setAnimation("crouchWalking")
    else
      args.velocity.x = 0
      args.animationClip:setAnimation("crouching")
    end

    -- "descend" state should be considered here

    -- Hardcoded height values should be changed in the future
    args.state.collisionBoxes[args.entity].height = 50
    if not love.keyboard.isDown("s") then
      args.state.collisionBoxes[args.entity].height = 100
      args.finiteStateMachine:setState("idle")
    end
  end,

  descend = function(args)
    args.state.collisionBoxes[args.entity].reactingWithClouds = false
    args.finiteStateMachine:setState("idle")
  end,

  punching = function (args)
    if args.animationClip:done() then
      args.finiteStateMachine:setState("idle")
    end
  end
}


function M.player(state)
  -- players depend on velocities and positions
  -- components.assertDependency(state, "players", "velocities", "positions")

  -- This for loop could be avoided if there is only one entity with a "player"
  -- component.
  for entity, player in pairs(state.players or {}) do
    if type(player) == "table" and player.control or player then
      local animationClips = state.animationClips or {}
      local finiteStateMachine = state.finiteStateMachines[entity]
      local clip = animationClips[entity] or animation.DummyAnimationClip(finiteStateMachine)
      local livingEntities = state.living or {}
      local livingEntity = livingEntities[entity] or {health=0,stamina=0}
      -- components.assertExistence(entity, "player", {velocity, "velocity",
      --                            {animationClip, "animationClip"},
      --                            {finiteStateMachine, "finiteStateMachine"},
      --                            {living, "living"}})
      local runStateLogic = statesLogic[finiteStateMachine.currentState]
      runStateLogic{
        state = state,
        entity = entity,
        finiteStateMachine = finiteStateMachine,
        velocity = state.velocities[entity],
        speedImpulses = state.speedImpulses[entity],
        animationClip = clip,
        living = livingEntity
      }
    end
  end
end


function M.playerAfterTerrainCollisionChecking(componentsTable)
  -- components.assertDependency(componentsTable, "players", "velocities")

  -- This for loop could be avoided if there is only one entity with a "player"
  -- component.
  for entity, player in pairs(componentsTable.players or {}) do
    local velocity = componentsTable.velocities[entity]
    local animationClips = componentsTable.animationClips or {}
    local finiteStateMachine = componentsTable.finiteStateMachines[entity]
    local animationClip = animationClips[entity] or animation.DummyAnimationClip(finiteStateMachine)
    -- components.assertExistence(entity, "player", {velocity, "velocity",
    --                            {animationClip, "animationClip"},
    --                            {finiteStateMachine, "finiteStateMachine"}})
    if finiteStateMachine.currentState == "idle" and velocity.x == 0 and
       velocity.y == 0 then
      animationClip:setAnimation("standing")
    end
  end
end

return M
