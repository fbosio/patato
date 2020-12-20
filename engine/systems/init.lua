local controller = require "engine.systems.controller"
local transporter = require "engine.systems.transporter"
local messenger = require "engine.systems.messenger"

local M = {}

function M.load(love)
  controller.load(love)
end

function M.update(dt, keys, st)
  controller.update(keys, st.input, st.velocity, st.impulseSpeed, st.menu)
  transporter.update(dt, st.velocity, st.position)
  messenger.update(st.collector, st.collectable, st.collisionBox)
end

function M.keypressed(key, keys, input, menu, inMenu)
  controller.keypressed(key, keys, input, menu, inMenu)
end

return M
