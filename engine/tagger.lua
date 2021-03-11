local M = {}

local id = 0
local tags

function M.clear()
  tags = {}
end

function M.tag(name)
  id = id + 1
  tags[name] = tags[name] or {}
  local ids = tags[name]
  ids[#ids+1] = id
  return id
end

function M.getId(name)
  return M.getIds(name)[1]
end

function M.getIds(name)
  return tags[name] or {}
end

function M.getName(entity)
  for name, ids in pairs(tags) do
    for _, v in ipairs(ids) do
      if entity == v then
        return name
      end
    end
  end
end

function M.remove(entity)
  tags[M.getName(entity)] = nil
end


M.clear()

return M
