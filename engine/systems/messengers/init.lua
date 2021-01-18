local climbing = require "engine.systems.messengers.climbing"
local collection = require "engine.systems.messengers.collection"
local collision = require "engine.systems.messengers.collision"

local M = {}

function M.update(dt, components, collectableEffects)
  climbing.update(dt, components)
  collection.update(components, collectableEffects)
  collision.update(dt, components.solid, components.collideable,
                   components.collisionBox, components.position,
                   components.velocity, components.gravitational,
                   components.climber)
end

return M
