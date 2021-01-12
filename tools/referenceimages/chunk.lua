io.input("config.lua")
local config = io.read("*a")

local M = {}

function M.getValue(field)
  return string.match(config, "M." .. field .. "%s*=%s*(%b{})")
end

return M
