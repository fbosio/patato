local controller = require "engine.systems.controller"
local transporter = require "engine.systems.transporter"
local messengers = require "engine.systems.messengers"
local animator = require "engine.systems.animator"
local garbagecollector = require "engine.systems.garbagecollector"
local renderer = require "engine.systems.renderer"
local loaders = require "engine.systems.loaders"

local M = {}

function M.load(love, entityTagger, config)
  local world = loaders.load(love, entityTagger, config)
  controller.load(love, entityTagger)
  animator.load(entityTagger)
  renderer.load(love, entityTagger)
  messengers.load(love, entityTagger)

  return world
end

function M.reload(level, inMenu)
  return loaders.reload(level, inMenu)
end

function M.update(dt, gameState, resources, physics)
  controller.update(gameState.hid)
  transporter.drag(dt, gameState.components, physics.gravity)
  messengers.update(dt, gameState)
  transporter.move(dt, gameState.components)
  animator.update(dt, gameState.components, resources)
  garbagecollector.update(gameState.components)
end

function M.draw(gameState, resources, release)
  messengers.draw(gameState)
  renderer.draw(gameState, resources.entities, release)
end

function M.keypressed(key, gameState)
  controller.keypressed(key, gameState.hid)
end

function M.keyreleased(key, gameState)
  controller.keyreleased(key, gameState.hid)
end

function M.joystickpressed(joystick, button, gameState)
  controller.joystickpressed(joystick, button, gameState.hid)
end

function M.joystickreleased(joystick, button, gameState)
  controller.joystickreleased(joystick, button, gameState.hid)
end

function M.joystickhat(joystick, hat, direction, gameState)
  controller.joystickhat(joystick, hat, direction, gameState.hid)
end

function M.joystickadded(joystick, gameState)
  controller.joystickadded(joystick, gameState.hid)
end

function M.joystickremoved(joystick, gameState)
  controller.joystickremoved(joystick, gameState.hid)
end

return M
