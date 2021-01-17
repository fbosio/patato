local collisionHelpers = require "engine.systems.messengers.collision.helpers"
local collide = collisionHelpers.collide


local M = {}

function M.update(dt, sv, climber, gravitational, sb, cb)
  collide.top(dt, sv, climber, gravitational, sb, cb)
end

return M