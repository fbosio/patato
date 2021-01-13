if not love then
  print("Usage: love <directory_of_this_file>")
  return
end

local levels = require "levels"
local surveyor = require "surveyor"
local photographer = require "photographer"
local copyist = require "copyist"

local levelData = {}
for name, level in pairs(levels) do
  local bounds = surveyor.measure(level)
  levelData[name] = bounds
  photographer.shoot(name, level, bounds)
end
copyist.write(levelData)

love.event.quit()
