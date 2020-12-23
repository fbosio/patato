local config
if not pcall(function() config = require "config" end) then
  config = {
    entities = {
      player = {
        input = {}
      }
    }
  }
end
if type(config) ~= "table" then
  local message = "Incorrect config, received " .. type(config) .. "."
  if type(config) == "boolean" and config then
    message = message .. "\n"
                      .. "Probably config.lua is empty or you forgot the "
                      .. '"return M" statement.'
  end
  error(message)
end

local entityTagger = require "engine.tagger"
local resourcemanager = require "engine.resourcemanager"
local systems = require "engine.systems"
local renderer = require "engine.renderer"

local M = {}

-- Löve2D events
function M.load()
  systems.load(love, entityTagger)
  resourcemanager.load(love, entityTagger)
  for k, v in pairs(resourcemanager.buildWorld(config)) do
    M[k] = v
  end
  M.collectableEffects = {}
  setmetatable(M.collectableEffects, {
    __index = function ()
      return function () end
    end
  })
  renderer.load(love, entityTagger)
end

function M.update(dt)
  systems.update(dt, M.hid, M.gameState.components, M.collectableEffects,
                 M.resources.animations)
end

function M.draw()
  renderer.draw(M.gameState.components, M.gameState.inMenu, M.resources)
end

function M.keypressed(key)
  systems.keypressed(key, M.hid, M.gameState.components.input,
                     M.gameState.components.menu, M.gameState.inMenu)
end

-- API
function M.startGame(levelName)
  M.gameState.inMenu = false
  resourcemanager.buildState(config, M, levelName)
end

function M.setMenuOption(entity, index, callback)
  local menu = M.gameState.components.menu
  if menu then
    menu[entityTagger.getId(entity)].callbacks[index] = callback
  end
end

function M.setCollectableEffect(name, callback)
  M.collectableEffects[name] = callback
end

function M.setAction(action, callback)
  M.hid.actions[action] = callback
end

return M
