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

function M.areOverlapped(tbox1, tbox2)
  return tbox1.left <= tbox2.right and tbox1.right >= tbox2.left
    and tbox1.top <= tbox2.bottom and tbox1.bottom >= tbox2.top
end

return M
