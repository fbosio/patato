local drawings = require "outline.drawings"
local display = require "outline.display"

--- Debug module
-- I could not name this module "debug" because there is already a library
-- named "debug" in lua.
local M = {}


function M.draw(componentsTable, positions)
  local r, g, b = love.graphics.getColor()

  local terrainPositions = positions or componentsTable.currentLevel

  -- Pasar a subrutinas
  local position

  -- Move terrain
  position = terrainPositions.terrain
  drawings.boundaries(position.boundaries)
  drawings.clouds(position.clouds)
  drawings.slopes(position.slopes)
  drawings.ladders(position.ladders)

  -- Move boxes
  if positions then
    position = positions.components
  else
    position = componentsTable.positions
  end
  if position then
    drawings.collisionBoxes(componentsTable.collisionBoxes, position)
    -- drawings.attackBoxes(componentsTable.animationClips, position)
    drawings.goals(componentsTable.goals, position)
    drawings.medkits(componentsTable.healing, position)
    drawings.pomodori(componentsTable.experienceEffect, position)
  end

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
