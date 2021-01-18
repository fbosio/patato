local iterators = require "engine.iterators"
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
  for _, c, cb, g, v, p in iterators.climber(components) do
    local translatedCB = getTranslatedBox(p, cb)

    local isClimberCollidingWithNoTrellises = true
    for trellisEntity, t, tCb, tP in iterators.trellis(components) do
      if t then
        local translatedTB = getTranslatedBox(tP, tCb)

        if areOverlapped(translatedCB, translatedTB) then
          isClimberCollidingWithNoTrellises = false
          if c.climbing then
            snapClimberToTrellis(translatedCB, translatedTB)
            stopClimber(dt, translatedCB, translatedTB, v)
            g.enabled = false
            if not c.trellis then
              v.y = 0
            end
            c.trellis = trellisEntity
          else
            c.trellis = nil
          end
        else
          c.trellis = nil
        end
      end
    end

    if isClimberCollidingWithNoTrellises then
      c.climbing = false
      g.enabled = true
    end
  end
end

return M
