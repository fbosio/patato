local climbing = require "engine.systems.messengers.climbing"
local collection = require "engine.systems.messengers.collection"
local collision = require "engine.systems.messengers.collision"

local M = {}

function M.update(dt, components, collectableEffects)
  climbing.update(components.climber, components.trellis,
                  components.collisionBox, components.position,
                  components.velocity)
  collection.update(components.collector, components.collectable,
                    collectableEffects, components.collisionBox,
                    components.position, components.garbage)
  collision.update(dt, components.solid, components.collideable,
                   components.collisionBox, components.position,
                   components.velocity, components.gravitational)
end

return M
