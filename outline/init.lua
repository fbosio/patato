local drawings = require "outline.drawings"
local display = require "outline.display"


--- Debug module
-- I could not name this module "debug" because there is already a library
-- named "debug" in lua.
local M = {}


local function moveTerrain(componentsTable, positions)
  local terrainPositions = positions or componentsTable.currentLevel
  local position = terrainPositions.terrain or {}
  drawings.boundaries(position.boundaries)
  drawings.clouds(position.clouds)
  drawings.slopes(position.slopes)
  drawings.ladders(position.ladders)
end


local function moveBoxes(componentsTable, positions)
  local position = positions and positions.components
                   or componentsTable.positions

  if position then
    drawings.collisionBoxes(componentsTable.collisionBoxes, position)
    -- drawings.attackBoxes(componentsTable.animationClips, position)
    drawings.goals(componentsTable.goals, position)
    drawings.medkits(componentsTable.healing, position)
    drawings.pomodori(componentsTable.experienceEffect, position)
  end
end


function M.draw(componentsTable, positions)
  local r, g, b = love.graphics.getColor()

  moveTerrain(componentsTable, positions)
  moveBoxes(componentsTable, positions)

  -- Reset drawing color
  love.graphics.setColor(r, g, b)
end


function M.debug(id, textFunction, args, red, green, blue)
  local r, g, b = love.graphics.getColor()
  display.add(id, textFunction, args, red, green, blue)

  -- Reset drawing color
  love.graphics.setColor(r, g, b)
end


return M
