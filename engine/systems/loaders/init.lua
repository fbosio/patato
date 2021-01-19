local configLoader = require "engine.systems.loaders.config"
local mode = require "engine.systems.loaders.mode"
local physics = require "engine.systems.loaders.physics"
local hid = require "engine.systems.loaders.hid"
local resources = require "engine.systems.loaders.resources"
local gamestate = require "engine.systems.loaders.gamestate"

local M = {}

function M.load(love, entityTagger, command, config)
  local loadedConfig = configLoader.load(config)
  local loadedHid = hid.load(loadedConfig)
  local gameState = gamestate.load(love, entityTagger, command, loadedHid,
                                   loadedConfig)
  return {
    release = mode.load(loadedConfig),
    physics = physics.load(loadedConfig),
    hid = loadedHid,
    resources = resources.load(love, loadedConfig),
    gameState = gameState
  }
end

function M.reload(level, inMenu)
  return gamestate.reload(level, inMenu)
end

return M
