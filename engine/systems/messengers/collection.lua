local iter = require "engine.iterators"
local helpers = require "engine.systems.helpers"
local getTranslatedBox = helpers.getTranslatedBox
local areOverlapped = helpers.areOverlapped


local M = {}

--[[
  fl = flap
]]

function M.update(components)
  for fl1Entity, fl1, fl1Box, fl1Pos in iter.flap(components) do
    fl1.overlap = nil
    if fl1.enabled then
      local fl1TBox = getTranslatedBox(fl1Pos, fl1Box)
      
      for fl2Entity, fl2, fl2Box, fl2Pos in iter.flap(components) do
        if fl1Entity ~= fl2Entity and fl2.enabled then
          local fl2TBox = getTranslatedBox(fl2Pos, fl2Box)
          
          if areOverlapped(fl1TBox, fl2TBox) then
            fl1.overlap = fl2Entity
            fl2.overlap = fl1Entity
          end
        end
      end
    end
  end
end

return M
