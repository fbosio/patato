local controller = require "engine.systems.controller"
local transporter = require "engine.systems.transporter"

local M = {}

function M.update(dt, keys, st)
  controller.update(keys, st.input, st.velocity, st.impulseSpeed)
  transporter.update(dt, st.velocity, st.position)
end

return M
