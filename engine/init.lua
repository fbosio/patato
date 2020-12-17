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

local resourcemanager = require "engine.resourcemanager"
local systems = require "engine.systems"
local renderer = require "engine.renderer"

local M = {}

-- Löve2D events
function M.load()
  systems.load(love)
  resourcemanager.load(love)
  for k, v in pairs(resourcemanager.buildWorld(config)) do
    M[k] = v
  end
  renderer.load(love)
end

function M.update(dt)
  systems.update(dt, M.keys, M.gameState)
end

function M.draw()
  renderer.draw(M)
end

function M.keypressed(key)
  systems.keypressed(key, M.keys, M.gameState.input, M.gameState.menu,
                     M.inMenu)
end

-- Public API
function M.startGame(levelName)
  M.inMenu = false
  resourcemanager.buildState(config, M, levelName)
end

function M.setMenuOption(entity, index, callback)
  if M.gameState.menu then
    M.gameState.menu[entity].callbacks[index] = callback
  end
end

return M
