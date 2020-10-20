local animation = require "components.animation"
local statemachine = require "components.statemachine"

local sprites = {}
local animations = {}
pcall(function()
  sprites = require "resources.sprites"
end)
pcall(function()
  animations = require "resources.animations"
end)


local M = {}


local function loadPosition(name, state, player)
  state.positions = state.positions or {}
  state.positions[name] = {
    x = player[1][1],
    y = player[1][2]
  }
end


local function loadVelocity(name, state)
  state.velocities = state.velocities or {}
  state.velocities[name] = {x=0, y=0}
end


local function loadStateMachine(name, state)
  state.stateMachines = state.stateMachines or {}
  state.stateMachines[name] = statemachine.StateMachine:new{
    currentState = "idle"
  }
end


local function loadSpeedImpulses(name, state)
  local speedImpulses = state.speedImpulses or {}
  speedImpulses[name] = speedImpulses[name] or {}
  speedImpulses[name].walk = speedImpulses[name].walk or 0
  speedImpulses[name].crouchWalk = speedImpulses[name].crouchWalk or 0
  speedImpulses[name].jump = speedImpulses[name].jump or 0
  speedImpulses[name].climb = speedImpulses[name].climb or 0
end


local function loadAnimationClip(name, state, spriteSheet)
  state.animationClips = state.animationClips or {}
  state.animationClips[name] = animation.AnimationClip:new{
    spritesData = sprites,
    animationsData = animations[name],
    spriteSheet = spriteSheet,
    currentAnimationName = "standing"
  }
end


function M.load(name, state, spriteSheet)
  local entitiesData = state.currentLevel.entitiesData or {}
  local player = entitiesData.player
  if player then
    loadPosition(name, state, player)
    loadVelocity(name, state)
    loadStateMachine(name, state)

    -- This might be removed when enemies are created
    local players = state.players or {}
    players[name] = players[name] or {}
    if players[name].control then
      state.living = {
        [name] = {health = 1}
      }
    end

    loadSpeedImpulses(name, state)
    loadAnimationClip(name, state, spriteSheet)
  end
end

return M
