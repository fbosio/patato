local loader = require "engine.loader"
local systems = require "engine.systems"

local M = {}

function M.load(path)
  local paths = {path, "config.yaml", "config.yml"}
  local read = ""
  for _, p in pairs(paths) do
    local file, msg = io.open(p, "r")
    if file then
      read = file:read("*a")
      file:close()
      break
    end
  end
  loader.init(love)
  local config = loader.loadFromString(read)
  for k, v in pairs(config) do M[k] = v end
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
