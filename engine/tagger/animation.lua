local M = {}

local id = 0
local tags = {}

function M.tag(entityName, animationName)
  id = id + 1
  tags[entityName] = tags[entityName] or {}
  tags[entityName][animationName] = id
  return id
end

function M.getId(entityName, animationName)
  return tags[entityName][animationName]
end

function M.getName(entityName, animationId)
  for k, v in pairs(tags[entityName] or {}) do
    if v == animationId then
      return k
    end
  end
end

return M
