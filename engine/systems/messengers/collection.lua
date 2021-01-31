local iter = require "engine.iterators"
local helpers = require "engine.systems.helpers"
local getTranslatedBox = helpers.getTranslatedBox
local areOverlapped = helpers.areOverlapped


local M = {}

--[[
  cr = collector,
  ce = collectable,
]]

function M.update(components, collectableEffects)
  for _, cr, crBox, crPos in iter.collector(components) do
    if cr.enabled then
      local crTBox = getTranslatedBox(crPos, crBox)
      
      for ceEntity, ce, ceBox, cePos in iter.collectable(components) do
        local ceTBox = getTranslatedBox(cePos, ceBox)
        
        if areOverlapped(crTBox, ceTBox) then
          collectableEffects[ce.name]()
          components.garbage[ceEntity] = true
        end
      end
    end
  end
end

return M
