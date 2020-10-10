local components = require "components"
local translate = require "systems.camera.translate"
local tweening = require "systems.camera.tweening"

local M = {}


function M.load(name, target, state)
  state.cameras = {
    [name] = true
  }  -- only one instance allowed, for now
  state.cameraTargets = {
    [name] = target
  }  -- only one instance allowed, for now

  state.positions = state.positions or {}
  state.positions[name] = {x=0, y=0}
end


--- Follow camera targets
function M.update(state, dt)
  for vcamEntity, isVcam in pairs(state.cameras or {}) do
    if isVcam then
      local targetEntity = state.cameraTargets[vcamEntity]

      local vcamPosition = state.positions[vcamEntity]
      local targetPosition = state.positions[targetEntity]
      -- components.assertExistence(vcamEntity, "camera",
      --                            {vcamPosition, "vcamPosition"})
      -- components.assertExistence(targetEntity, "cameraTarget",
      --                            {targetPosition, "targetPosition"})

      -- Movement constraints here
      tweening.exp(vcamPosition, targetPosition, dt, 25)
      -- tweening.linear(vcamPosition, targetPosition, dt)
    end
  end
end


--- Return the results of applying coordinate translations
function M.positions(state)
  for vcamEntity, isVcam in pairs(state.cameras or {}) do

    if isVcam then
      local vcamPosition = state.positions[vcamEntity]

      local translated = {
        terrain = {},
        components = {}
      }

      translated.components = translate.boxes(state.positions,
                                              vcamEntity, vcamPosition)
      translated.terrain = translate.terrain(state.currentLevel.terrain,
                                             state.ladders,
                                             vcamPosition)

      -- Done, now return a table with all the moved positions
      return translated
    end

  end
end

return M
