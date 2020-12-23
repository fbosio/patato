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

function M.update(dt, keys, control, st, collectableEffects, animations)
  controller.update(keys, control, st.input, st.velocity, st.impulseSpeed,
                    st.menu)
  transporter.update(dt, st.velocity, st.position, st.collisionBox)
  messenger.update(st.collector, st.collectable, collectableEffects,
                   st.collisionBox, st.garbage)
  animator.update(dt, st.animation, animations)
  garbagecollector.update(st)
end

function M.keypressed(key, keys, control, input, menu, inMenu)
  controller.keypressed(key, keys, control, input, menu, inMenu)
end

return M
