local controller = require "engine.systems.controller"
local transporter = require "engine.systems.transporter"
local messenger = require "engine.systems.messenger"
local garbagecollector = require "engine.systems.garbagecollector"

local M = {}

function M.load(love)
  controller.load(love)
end

function M.update(dt, keys, st)
  controller.update(keys, st.input, st.velocity, st.impulseSpeed, st.menu)
  transporter.update(dt, st.velocity, st.position, st.collisionBox)
  messenger.update(st.collector, st.collectable, st.collisionBox, st.garbage)
  garbagecollector.update(st)
end

function M.keypressed(key, keys, input, menu, inMenu)
  controller.keypressed(key, keys, input, menu, inMenu)
end

return M
