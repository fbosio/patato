local controller = require "engine.systems.controller"
local transporter = require "engine.systems.transporter"
local config = require "config"

local M = {}

function M.load(love)
  controller.load(love)
end

function M.update(dt, keys, st)
  controller.update(keys, st.input, st.velocity, st.impulseSpeed, st.menu)
  transporter.update(dt, st.velocity, st.position)
end

function M.keypressed(key, menu)
  controller.keypressed(key, menu)
end

return M
