local M = {}

function M.getTranslatedBox(position, box)
  local x = position.x - box.origin.x
  local y = position.y - box.origin.y
  return {
    origin = {x = box.origin.x, y = box.origin.y},
    width = box.width,
    height = box.height,
    left = x,
    right = x + box.width,
    top = y,
    bottom = y + box.height,
    horizontalCenter = x + box.width/2,
    verticalCenter = y + box.height/2
  }
end

return M
