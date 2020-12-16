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

local M = {}

function M.load()
  systems.load(love)
  resourcemanager.load(love)
  for k, v in pairs(resourcemanager.buildWorld(config)) do
    M[k] = v
  end
end

function M.update(dt)
  systems.update(dt, M.keys, M.gameState)
end

function M.draw()
  for entity, position in pairs(M.gameState.position or {}) do
    love.graphics.points({position.x, position.y})
  end
end

return M
