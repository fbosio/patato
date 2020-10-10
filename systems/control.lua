local components = require "components"
local animation = require "components.animation"
local M = {}


local holdingJumpKey


local function checkWalkInput(args)
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
end


local function checkJumpInput(args)
  if love.keyboard.isDown("k") and args.velocity.y == 0 and not holdingJumpKey then
    args.finiteStateMachine:setState("startingJump")
    args.animationClip:setAnimation("startingJump")
    holdingJumpKey = true
  elseif not love.keyboard.isDown("k") and holdingJumpKey then
    holdingJumpKey = false
  end
end


local function checkCrouchInput(args)
  if not love.keyboard.isDown("k") and love.keyboard.isDown("s")
      and args.velocity.y == 0 then
    args.finiteStateMachine:setState("crouching")
  end
end


local function checkClimbInput(args)
  if args.collisionBox.ladder and (love.keyboard.isDown("w")
      or love.keyboard.isDown("s")) then
    local weights = args.state.weights or {}
    weights[args.entity] = nil
    args.collisionBox.climbing = true
    args.finiteStateMachine:setState("climbing")
    args.animationClip:setAnimation("climbingIdle")
  end
end


local statesLogic = {
  idle = function (args)
    checkWalkInput(args)  

    if args.velocity.y ~= 0 then
      args.animationClip:setAnimation("jumping")
    end

    checkJumpInput(args)

    if love.keyboard.isDown("j") then
      args.finiteStateMachine:setState("hurt")
    end

    checkCrouchInput(args)

    if love.keyboard.isDown("l") then
      args.velocity.x = 0
      args.finiteStateMachine:setState("punching")
      args.animationClip:setAnimation("punching")
    end

    checkClimbInput(args)
  end,

  startingJump = function (args)
    if args.animationClip:done() then
      if args.collisionBox.climbing then
        if love.keyboard.isDown("a") and not love.keyboard.isDown("d") then
          args.velocity.x = -args.speedImpulses.walk
          args.animationClip.facingRight = false
        elseif not love.keyboard.isDown("a") and love.keyboard.isDown("d") then
          args.velocity.x = args.speedImpulses.walk
          args.animationClip.facingRight = true
        end
        args.collisionBox.climbing = false
        args.finiteStateMachine:setState("outOfLadder", 0.3)
      else
        args.finiteStateMachine:setState("idle")
      end
      args.animationClip:setAnimation("jumping")
      args.velocity.y = -args.speedImpulses.jump
    end
  end,

  hurt = function (args)
    args.living.health = args.living.health - 1
    args.living.stamina = args.living.stamina
                          and math.max(0, args.living.stamina - 25)
    
    if args.collisionBox.hurtFallHeight then
      args.living.health = 0
      args.velocity.x = 0
      args.finiteStateMachine:setState("lyingDown", 1.5)
      args.animationClip:setAnimation("lyingDown")
    elseif args.living.health == 0
        or (args.living.stamina and args.living.stamina == 0) then
      args.finiteStateMachine:setState("flyingHurt")
      local collectors = args.state.collectors or {}
      collectors[args.entity] = false
      args.animationClip:setAnimation("flyingHurt")
      args.velocity.x = (args.animationClip.facingRight and -1 or 1)
                        * args.speedImpulses.walk
      args.velocity.y = -args.speedImpulses.jump
    else
      args.finiteStateMachine:setState("hit", 0.5)
      args.animationClip:setAnimation("hitByHighPunch")
    end
  end,

  hit = function (args)
    --velocity.x must be set to a property value from another component
    args.velocity.x = (args.animationClip.facingRight and -1 or 1)
                      * args.speedImpulses.walk / 3
    if args.animationClip:done() then
      args.finiteStateMachine:setState("idle")
    end
  end,

  flyingHurt = function (args)
    local maxFallSpeed = args.collisionBox.maxFallSpeed or 5000
    if args.velocity.y == 0 then
      args.velocity.x = 0
      args.finiteStateMachine:setState("lyingDown", 1)
      args.animationClip:setAnimation("lyingDown")
    elseif args.velocity.y > maxFallSpeed then
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
  end,

  climbing = function (args)
    local weights = args.state.weights or {}

    if args.collisionBox.climbing then
      if love.keyboard.isDown("w") and not love.keyboard.isDown("s") then
        args.velocity.y = -args.speedImpulses.climb
        args.animationClip:setAnimation("climbingUp")
      elseif love.keyboard.isDown("s") and not love.keyboard.isDown("w") then
        args.velocity.y = args.speedImpulses.climb
        args.animationClip:setAnimation("climbingDown")
      else
        args.velocity.y = 0
        args.animationClip:setAnimation("climbingIdle")
      end

      if love.keyboard.isDown("k") then
        weights[args.entity] = true
        args.finiteStateMachine:setState("startingJump")
        args.animationClip:setAnimation("climbingStartingJump")
      end
    
    else
      weights[args.entity] = true
      args.finiteStateMachine:setState("idle")
    end
  end,

  outOfLadder = function (args)
    if args.finiteStateMachine.stateTime == 0 then
      args.finiteStateMachine:setState("idle")
    end
  end
}


function M.player(state)
  -- players depend on velocities and positions
  -- components.assertDependency(state, "players", "velocities", "positions")

  -- This for loop could be avoided if there is only one entity with a "player"
  -- component.
  local finiteStateMachines = state.finiteStateMachines
  if finiteStateMachines then
    for entity, player in pairs(state.players or {}) do
      if type(player) == "table" and player.control or player then
        local animationClips = state.animationClips or {}
        local finiteStateMachine = finiteStateMachines[entity]
        local clip = animationClips[entity] or
                     animation.DummyAnimationClip(finiteStateMachine)
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
          living = livingEntity,
          collisionBox = state.collisionBoxes[entity]
        }
      end
    end
  end
end


-- move to animation module
function M.playerAfterTerrainCollisionChecking(componentsTable)
  -- components.assertDependency(componentsTable, "players", "velocities")
  local velocities = componentsTable.velocities
  local finiteStateMachines = componentsTable.finiteStateMachines

  if velocities and finiteStateMachines then
    -- This for loop could be avoided if there is only one entity with a "player"
    -- component.
    for entity, player in pairs(componentsTable.players or {}) do
      local velocity = velocities[entity]
      local animationClips = componentsTable.animationClips or {}
      local finiteStateMachine = componentsTable.finiteStateMachines[entity]
      local animationClip = animationClips[entity] or
                            animation.DummyAnimationClip(finiteStateMachine)
      -- components.assertExistence(entity, "player", {velocity, "velocity",
      --                            {animationClip, "animationClip"},
      --                            {finiteStateMachine, "finiteStateMachine"}})
      if finiteStateMachine.currentState == "idle" and velocity.x == 0 and
         velocity.y == 0 then
        animationClip:setAnimation("standing")
      end
    end
  end
end


return M
