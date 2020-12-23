local animator = require "engine.systems.animator"
local controller = require "engine.systems.controller"
local transporter = require "engine.systems.transporter"
local messenger = require "engine.systems.messenger"
local garbagecollector = require "engine.systems.garbagecollector"

local M = {}

function M.load(love, entityTagger)
  controller.load(love)
  animator.load(entityTagger)
end

function M.update(dt, keys, hid, components, collectableEffects, animations)
  controller.update(keys, hid, components.input, components.velocity,
                    components.impulseSpeed, components.menu)
  transporter.update(dt, components.velocity, components.position,
                     components.collisionBox)
  messenger.update(components.collector, components.collectable,
                   collectableEffects, components.collisionBox,
                   components.garbage)
  animator.update(dt, components.animation, animations)
  garbagecollector.update(components)
end

function M.keypressed(key, keys, hid, input, menu, inMenu)
  controller.keypressed(key, keys, hid, input, menu, inMenu)
end

return M
