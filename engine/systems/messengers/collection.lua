local helpers = require "engine.systems.messengers.helpers"
local getTranslatedBox = helpers.getTranslatedBox
local areOverlapped = helpers.areOverlapped


local M = {}

function M.update(collectors, collectables, collectableEffects,
                  collisionBoxes, positions, garbage)
  for collectorEntity, _ in pairs(collectors or {}) do
    local position1 = positions[collectorEntity]
    local box1 = getTranslatedBox(position1, collisionBoxes[collectorEntity])

    for collectableEntity, collectable in pairs(collectables or {}) do
      local position2 = positions[collectableEntity]
      local box2 = getTranslatedBox(position2,
                                    collisionBoxes[collectableEntity])

      if areOverlapped(box1, box2) then
        collectableEffects[collectable.name]()
        garbage[collectableEntity] = true
      end
    end
  end
end

return M
