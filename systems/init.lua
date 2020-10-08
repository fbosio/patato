local animation = require "systems.animation"
local camera = require "systems.camera"
local terrain = require "systems.terrain"
local mruv = require "systems.mruv"
local control = require "systems.control"
local items = require "systems.items"
local goals = require "systems.goals"
local fsm = require "systems.fsm"
local living = require "systems.living"
local attack = require "systems.attack"


local M = {}

function M.update(state, dt)
  camera.update(state, dt)

  items.update(state)

  control.player(state)
  attack.collision(state)
  currentLevel = goals.update(state, currentLevel)

  mruv.gravity(state, dt)
  terrain.collision(state, state.currentLevel.terrain, dt)
  control.playerAfterTerrainCollisionChecking(state)
  mruv.movement(state, dt)
  living.staminaSupply(state, dt)
  animation.animator(state, dt)
  fsm.finiteStateMachineRunner(state, dt)

  return currentLevel
end

return M
