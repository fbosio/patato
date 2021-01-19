local iter = require "engine.iterators"
local helpers = require "engine.systems.helpers"
local rectangle = require "engine.systems.messengers.collision.rectangle"
local triangle = require "engine.systems.messengers.collision.triangle"
local cloud = require "engine.systems.messengers.collision.cloud"
local getTranslatedBox = helpers.getTranslatedBox

local M = {}

--[[
  s = solid,
  c = collideable,
]]

function M.update(dt, components)
  for _, s, climber, sb, grav, sv, sp in iter.solid(components) do
    local translatedSB = getTranslatedBox(sp, sb)

    for cEntity, c, cb, cp in iter.collideable(components) do
      local translatedCB = getTranslatedBox(cp, cb)

      if cb.height > 0 then
        if c.normalPointingUp == nil
            or c.rising == nil then
          rectangle.update(dt, components.collideable,
                           components.collisionBox, components.position,
                           sv, climber, grav, translatedSB, translatedCB,
                           s.slope)
        else
          triangle.update(dt, components.collideable,
                          components.collisionBox, components.position,
                          sv, c, s, climber, grav, translatedSB, translatedCB,
                          cEntity)
        end
      else
        cloud.update(dt, sv, climber, grav, translatedSB, translatedCB)
      end
    end
  end
end

return M
