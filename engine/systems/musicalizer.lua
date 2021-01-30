local iter = require "engine.iterators"

local M = {}

function M.load(world)
  M.resources = world.resources
  M.reload(world.gameState.components)
end

function M.reload(components)
  local _, jukebox = iter.jukebox()(components)
  if jukebox then
    local bgm = M.resources.sounds.bgm
    for _, source in pairs(bgm) do
      if source:isPlaying() then
        source:stop()
      end
    end
    bgm[jukebox.bgm]:play()
  end
end

return M
