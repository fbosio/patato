local animator = require "engine.systems.animator"
local collider = require "engine.systems.collider"
local controller = require "engine.systems.controller"
local transporter = require "engine.systems.transporter"
local messenger = require "engine.systems.messenger"
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
  collider.update(dt, components.solid, components.collideable,
                  components.collisionBox, components.position,
                  components.velocity)
  transporter.move(dt, components.velocity, components.position)
  messenger.update(components.collector, components.collectable,
                   collectableEffects, components.collisionBox,
                   components.position, components.garbage)
  animator.update(dt, components.animation, animationResources)
  garbagecollector.update(components)
end

function M.keypressed(key, hid, components)
  controller.keypressed(key, hid, components)
end

return M
