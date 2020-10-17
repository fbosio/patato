local drawings = require "outline.drawings"
local display = require "outline.display"


--- Debug module
-- I could not name this module "debug" because there is already a library
-- named "debug" in lua.
local M = {}


local function moveTerrain(state, positions)
  local terrainPositions = positions or state.currentLevel
  local position = terrainPositions.terrain or {}
  drawings.boundaries(position.boundaries)
  drawings.clouds(position.clouds)
  drawings.slopes(position.slopes)
  drawings.ladders(position.loadedLadders)
end


local function moveBoxes(state, positions)
  local position = positions and positions.components
                   or state.positions

  if position then
    drawings.collisionBoxes(state.collisionBoxes, position)
    -- drawings.attackBoxes(state.animationClips, position)
    drawings.goals(state.goals, position)
    drawings.medkits(state.healing, position)
    drawings.pomodori(state.experienceEffect, position)
  end
end


function M.draw(state, positions)
  local r, g, b = love.graphics.getColor()

  moveTerrain(state, positions)
  moveBoxes(state, positions)

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
