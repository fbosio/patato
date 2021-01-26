local M = {}

-- Make all submodules visible from this module
local path = "resources/metadata"
local files = love.filesystem.getDirectoryItems(path)
for _, file in ipairs(files) do
  local name = string.gsub(file, ".lua$", "")
  if name ~= "init" and name ~= file then
    M[name] = require("resources.metadata." .. name)
  end
end

return M
