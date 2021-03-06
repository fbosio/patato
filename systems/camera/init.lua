local components = require "components"
local translate = require "systems.camera.translate"
local tweening = require "systems.camera.tweening"

local M = {}


function M.load(name, target, state)
  local entitiesData = state.currentLevel.entitiesData or {}
  local boundaries = entitiesData.cameraBoundaries or {}
  state.cameras = {
    [name] = {
      target = target,
      boundaries = boundaries[1]
    }
  }  -- only one instance allowed, for now

  state.positions = state.positions or {}
  state.positions[name] = {x=0, y=0}
end


local function updatePositionWithinBoundaries(targetPosition, boundaries,
                                              width, height)
  local x1 = math.min(boundaries[1], boundaries[3])
  local x2 = math.max(boundaries[1], boundaries[3])
  local y1 = math.min(boundaries[2], boundaries[4])
  local y2 = math.max(boundaries[2], boundaries[4])

  if x2 - x1 < width then
    x2 = x1 + width
  end

  if y2 - y1 < height then
    y2 = y1 + height
  end

  if targetPosition.x < x1 + width/2 then
    targetPosition.x = x1 + width/2
  elseif targetPosition.x > x2 - width/2 then
    targetPosition.x = x2 - width/2
  end

  if targetPosition.y < y1 + height/2 then
    targetPosition.y = y1 + height/2
  elseif targetPosition.y > y2 - height/2 then
    targetPosition.y = y2 - height/2
  end
end


--- Follow camera targets
function M.update(state, dt)
  for vcamEntity, vcam in pairs(state.cameras or {}) do
    if vcam then
      local targetEntity = vcam.target
      local width, height = love.graphics.getDimensions()
      local targetPosition = state.positions[targetEntity]
        or {x=width/2, y=height/2}
      local newTargetPosition = {
        x = targetPosition.x,
        y = targetPosition.y
      }

      if vcam.boundaries then
        updatePositionWithinBoundaries(newTargetPosition, vcam.boundaries,
                                       width, height)
      end

      local vcamPosition = state.positions[vcamEntity]
      tweening.exp(vcamPosition, newTargetPosition, dt, 25)
      -- tweening.linear(vcamPosition, newTargetPosition, dt, {threshold=10,
      --                 multiplier=state.speedImpulses.patato.walk})
    end
  end
end


--- Return the results of applying coordinate translations
function M.positions(state)
  for vcamEntity, vcam in pairs(state.cameras or {}) do
    if vcam then
      local vcamPosition = state.positions[vcamEntity]

      local translated = {
        terrain = {},
        components = {}
      }

      translated.components = translate.boxes(state.positions,
                                              vcamEntity, vcamPosition)
      translated.terrain = translate.terrain(state.currentLevel.terrain,
                                             vcamPosition)

      -- Done, now return a table with all the moved positions
      return translated
    end
  end
end


return M
