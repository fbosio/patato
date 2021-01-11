local M = {}

-- Make all submodules visible from this module
for _, file in ipairs(love.filesystem.getDirectoryItems("resources")) do
  local name = string.gsub(file, ".lua$", "")
  if name ~= "init" and name ~= file then
    M[name] = require("resources." .. name)
  end
end

return M
