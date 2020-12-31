local M = {}

local id = 0
local tags = {}

function M.tag(name)
  id = id + 1
  tags[name] = tags[name] or {}
  local ids = tags[name]
  ids[#ids+1] = id
  return id
end

function M.getId(name)
  local ids = tags[name] or {}
  if #ids == 1 then
    return ids[1]
  end
end

function M.getIds(name)
  return tags[name]
end

function M.getName(entity)
  for name, ids in pairs(tags) do
    for _, id in ipairs(ids) do
      if entity == id then
        return name
      end
    end
  end
end

return M
