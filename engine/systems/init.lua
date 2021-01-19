local controller = require "engine.systems.controller"
local transporter = require "engine.systems.transporter"
local messengers = require "engine.systems.messengers"
local animator = require "engine.systems.animator"
local garbagecollector = require "engine.systems.garbagecollector"
local renderer = require "engine.systems.renderer"
local loaders = require "engine.systems.loaders"

local M = {}

function M.load(love, entityTagger, command, config)
  local world = loaders.load(love, entityTagger, command, config)
  controller.load(love, entityTagger)
  animator.load(entityTagger)
  renderer.load(love, entityTagger)
  messengers.load(love, entityTagger)

  return world
end

function M.reload(level, inMenu)
  return loaders.reload(level, inMenu)
end

function M.update(dt, hid, gameState, resources, physics)
  controller.update(hid, gameState.components)
  transporter.drag(dt, gameState.components, physics.gravity)
  messengers.update(dt, gameState)
  transporter.move(dt, gameState.components)
  animator.update(dt, gameState.components, resources)
  garbagecollector.update(gameState.components)
end

function M.draw(gameState, resources, release)
  messengers.draw(gameState)
  renderer.draw(gameState, resources, release)
end

function M.keypressed(key, hid, components)
  controller.keypressed(key, hid, components)
end

function M.keyreleased(key, hid, components)
  controller.keyreleased(key, hid, components)
end

function M.joystickpressed(joystick, button, hid, components)
  controller.joystickpressed(joystick, button, hid, components)
end

function M.joystickreleased(joystick, button, hid, components)
  controller.joystickreleased(joystick, button, hid, components)
end

function M.joystickhat(joystick, hat, direction, hid, components)
  controller.joystickhat(joystick, hat, direction, hid, components)
end

function M.joystickadded(joystick, hid)
  controller.joystickadded(joystick, hid)
end

function M.joystickremoved(joystick, hid)
  controller.joystickremoved(joystick, hid)
end

return M
