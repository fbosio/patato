local iter = require "engine.iterators"
local helpers = require "engine.systems.messengers.helpers"
local getTranslatedBox = helpers.getTranslatedBox
local areOverlapped = helpers.areOverlapped
local translate = helpers.translate


local M = {}

--[[
  cb = climber box,
  tb = trellis box,
]]

local function snapClimberToTrellis(cb, tb)
  if cb.left < tb.left then
    translate.left(cb, tb.left)
  end
  if cb.right > tb.right then
    translate.right(cb, tb.right)
  end
  if cb.top < tb.top then
    translate.top(cb, tb.top)
  end
end

local function stopClimber(dt, cb, tb, cv)
  if cb.left >= tb.left and cb.left + cv.x*dt < tb.left then
    cv.x = 0
    translate.left(cb, tb.left)
  end
  if cb.right <= tb.right and cb.right + cv.x*dt > tb.right then
    cv.x = 0
    translate.right(cb, tb.right)
  end
  if cb.top >= tb.top and cb.top + cv.y*dt < tb.top then
    cv.y = 0
    translate.top(cb, tb.top)
  end
end

function M.update(dt, components)
  for _, climber, cBox, grav, vel, pos in iter.climber(components) do
    local translatedCB = getTranslatedBox(pos, cBox)

    local isClimberCollidingWithNoTrellises = true
    for trellisEntity, isTrellis, tBox, tPos in iter.trellis(components) do
      if isTrellis then
        local translatedTB = getTranslatedBox(tPos, tBox)

        if areOverlapped(translatedCB, translatedTB) then
          isClimberCollidingWithNoTrellises = false
          if climber.climbing then
            snapClimberToTrellis(translatedCB, translatedTB)
            stopClimber(dt, translatedCB, translatedTB, vel)
            grav.enabled = false
            if not climber.trellis then
              vel.y = 0
            end
            climber.trellis = trellisEntity
          else
            climber.trellis = nil
          end
        else
          climber.trellis = nil
        end
      end
    end

    if isClimberCollidingWithNoTrellises then
      climber.climbing = false
      grav.enabled = true
    end
  end
end

return M
