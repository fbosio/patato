local entities = require "entities"
local getCoordinates = require "box".getCoordinates

local M = {}

local function reveal(data, box, bounds)
  for x = box[1]-bounds[1], box[3]-bounds[1]-1 do
    for y = box[2]-bounds[2], box[4]-bounds[2]-1 do
      data:setPixel(x, y, 0, 0, 1, 1)
    end
  end
end

function M.shoot(name, level, bounds)
  local data = love.image.newImageData(bounds:getWidth(), bounds:getHeight())
  for _, boxes in entities.rectangle.pairs(level) do
    if type(boxes[1]) == "table" then
      for _, box in ipairs(boxes) do
        reveal(data, getCoordinates(box), bounds)
      end
    else
      reveal(data, getCoordinates(boxes), bounds)
    end
  end

  local file = assert(io.open("resources/" .. name .. ".png", "wb"))
  file:write(data:encode("png"):getString())
  file:close()
end

return M
