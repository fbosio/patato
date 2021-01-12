local M = {}

local function round(x)
  local f = math.floor(x)
  if x == f then return f else return math.floor(x + 0.5) end
end

function M.getCoordinates(box)
  local x1 = round(math.min(box[1], box[3]))
  local y1 = round(math.min(box[2], box[4] or box[2]))
  local x2 = round(math.max(box[1], box[3]))
  local y2 = round(math.max(box[2], box[4] or box[2]))
  return {x1, y1, x2, y2}
end

return M
