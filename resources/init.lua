local M = {}

-- Make all submodules visible from this module
for _, directory in ipairs{"", "images", "sounds"} do
  local path = "resources/" .. directory
  local files = love.filesystem.getDirectoryItems(path)
  local target
  if directory == "" then
    target = M
  else
    M[directory] = {}
    target = M[directory]
  end
  for _, file in ipairs(files) do
    if love.filesystem.getInfo(path .. "/" .. file).type == "file" then
      local name = string.gsub(file, ".lua$", "")
      if name ~= "init" and name ~= file then
        target[name] = require("resources." .. directory .. "." .. name)
      end
    end
  end
end

return M
