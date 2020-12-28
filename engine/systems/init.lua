local animator = require "engine.systems.animator"
local collider = require "engine.systems.collider"
local controller = require "engine.systems.controller"
local transporter = require "engine.systems.transporter"
local messenger = require "engine.systems.messenger"
local garbagecollector = require "engine.systems.garbagecollector"

local M = {}

function M.load(love, entityTagger)
  controller.load(love)
  animator.load(entityTagger)
end

function M.update(dt, hid, components, collectableEffects, animationResources,
                  physics)
  controller.update(hid, components)
  collider.update(dt, components.solid, components.collideable,
                  components.collisionBox, components.position,
                  components.velocity)
  transporter.update(dt, components.velocity, components.position,
                     physics.gravity, components.gravitational)
  messenger.update(components.collector, components.collectable,
                   collectableEffects, components.collisionBox,
                   components.position, components.garbage)
  animator.update(dt, components.animation, animationResources)
  garbagecollector.update(components)
end

function M.keypressed(key, hid, input, menu, inMenu)
  controller.keypressed(key, hid, input, menu, inMenu)
end

return M
