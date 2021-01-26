local M = {}

-- Make metadata visible from this module
do
  local path = "resources/metadata"
  local files = love.filesystem.getDirectoryItems(path)
  for _, file in ipairs(files) do
    local name = string.gsub(file, ".lua$", "")
    if name ~= "init" and name ~= file then
      M[name] = require("resources.metadata." .. name)
    end
  end
end

-- Store soundfile paths
M.sounds = {}
do
  local path = "resources/sounds"
  for _, subdirectory in ipairs{"bgm", "sfx"} do
    local fullPath = path .. "/" .. subdirectory
    local files = love.filesystem.getDirectoryItems(fullPath)
    M.sounds[subdirectory] = {}
    for _, file in ipairs(files) do
      local name = string.gsub(file, ".ogg$", "")
      if name ~= file then
        M.sounds[subdirectory][name] = fullPath .. "/" .. file
      end
    end
  end
end

return M
