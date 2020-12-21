local M = {}

local id = 0
local tags = {}

function M.tag(name)
  id = id + 1
  tags[name] = id
  return id
end

function M.getId(name)
  return tags[name]
end

function M.getName(entity)
  for k, v in pairs(tags) do
    if v == entity then
      return k
    end
  end
end

return M
