if not love then
  print("Usage: love <directory_of_this_file>")
  return
end

local levels = require "levels"
local surveyor = require "surveyor"
local photographer = require "photographer"
local copyist = require "copyist"

local origins = {}
for name, level in pairs(levels) do
  local bounds = surveyor.measure(level)
  origins[name] = {bounds[1], bounds[2]}
  photographer.shoot(name, level, bounds)
end
copyist.write(origins)

love.event.quit()
