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

  return world
end

function M.reload(level, inMenu)
  return loaders.reload(level, inMenu)
end

function M.update(dt, hid, components, collectableEffects, resources,
                  physics)
  controller.update(hid, components)
  transporter.drag(dt, components.velocity, components.gravitational,
                   physics.gravity)
  messengers.update(dt, components, collectableEffects)
  transporter.move(dt, components.velocity, components.position)
  animator.update(dt, components.animation, resources)
  garbagecollector.update(components)
end

function M.draw(components, inMenu, resources, release)
  renderer.draw(components, inMenu, resources, release)
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
