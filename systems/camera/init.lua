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


--- Follow camera targets
function M.update(state, dt)
  for vcamEntity, vcam in pairs(state.cameras or {}) do
    if vcam then
      local targetEntity = vcam.target

      local vcamPosition = state.positions[vcamEntity]
      local _targetPosition = state.positions[targetEntity]
      local targetPosition = {  -- copy table
        x = _targetPosition.x,
        y = _targetPosition.y
      }

      if vcam.boundaries then
        local width, height = love.graphics.getDimensions()
        local x1 = math.min(vcam.boundaries[1], vcam.boundaries[3])
        local x2 = math.max(vcam.boundaries[1], vcam.boundaries[3])
        local y1 = math.min(vcam.boundaries[2], vcam.boundaries[4])
        local y2 = math.max(vcam.boundaries[2], vcam.boundaries[4])

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

      -- Movement constraints here
        tweening.exp(vcamPosition, targetPosition, dt, 25)
  --       tweening.linear(vcamPosition, targetPosition, dt, {threshold=10,
  --           multiplier=state.speedImpulses.patato.walk})
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
