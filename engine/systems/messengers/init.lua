local camera = require "engine.systems.messengers.camera"
local climbing = require "engine.systems.messengers.climbing"
local collection = require "engine.systems.messengers.collection"
local collision = require "engine.systems.messengers.collision"

local M = {}

function M.load(love, entityTagger)
  camera.load(love, entityTagger)
end

function M.update(dt, gameState)
  camera.update(gameState.components, gameState.camera)
  climbing.update(dt, gameState.components)
  collection.update(gameState.components, gameState.collectableEffects)
  collision.update(dt, gameState.components)
end

function M.draw(gameState)
  camera.draw(gameState.components, gameState.camera)
end

return M
