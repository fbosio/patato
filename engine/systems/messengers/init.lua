local camera = require "engine.systems.messengers.camera"
local climbing = require "engine.systems.messengers.climbing"
local collection = require "engine.systems.messengers.collection"
local collision = require "engine.systems.messengers.collision"

local M = {}

function M.load(love, entityTagger)
  camera.load(love, entityTagger)
end

function M.update(dt, components, collectableEffects, cameraData)
  camera.update(components, cameraData)
  climbing.update(dt, components)
  collection.update(components, collectableEffects)
  collision.update(dt, components)
end

function M.draw(components, cameraData)
  camera.draw(components, cameraData)
end

return M
