local controller = require "engine.systems.controller"
local transporter = require "engine.systems.transporter"
local messengers = require "engine.systems.messengers"
local animator = require "engine.systems.animator"
local garbagecollector = require "engine.systems.garbagecollector"

local M = {}

function M.load(love, entityTagger)
  controller.load(love, entityTagger)
  animator.load(entityTagger)
end

function M.update(dt, hid, components, collectableEffects, animationResources,
                  physics)
  controller.update(hid, components)
  transporter.drag(dt, components.velocity, components.gravitational,
                   physics.gravity)
  messengers.update(dt, components, collectableEffects)
  transporter.move(dt, components.velocity, components.position)
  animator.update(dt, components.animation, animationResources)
  garbagecollector.update(components)
end

function M.keypressed(key, hid, components)
  controller.keypressed(key, hid, components)
end

function M.keyreleased(key, hid, components)
  controller.keyreleased(key, hid, components)
end

return M
