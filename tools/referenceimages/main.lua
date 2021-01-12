if not love then
  print("Usage: love <directory_of_this_file>")
  return
end

local levels = require "levels"
local surveyor = require "surveyor"
local photographer = require "photographer"

for name, level in pairs(levels) do
  local bounds = surveyor.measure(level)
  photographer.shoot(name, level, bounds)
end

love.event.quit()
