local entities = require "entities"
local getCoordinates = require "box".getCoordinates

local M = {}

local function getPaddedBounds(bounds)
  local padded = {}
  for k, v in pairs(bounds) do
    padded[k] = v
  end
  local oldWidth = bounds:getWidth()
  local newWidth = 2^(1 + math.ceil(math.log(oldWidth)/math.log(2)))
  local dx = math.floor((newWidth-bounds:getWidth()) / 2)
  padded[1] = padded[1] - dx
  padded[3] = padded[3] + newWidth - oldWidth - dx
  local oldHeight = bounds:getHeight()
  local newHeight = 2^(1 + math.ceil(math.log(oldHeight)/math.log(2)))
  local dy = math.floor((newHeight-bounds:getHeight()) / 2)
  padded[2] = padded[2] - dy
  padded[4] = padded[4] + newHeight - oldHeight - dy
  return padded
end

local function developRectangle(data, box, bounds, rgba)
  local coordinates = getCoordinates(box)
  for x = coordinates[1] - bounds[1], coordinates[3] - bounds[1] - 1 do
    for y = coordinates[2] - bounds[2], coordinates[4] > coordinates[2]
            and coordinates[4] - bounds[2] - 1 or coordinates[2] - bounds[2] do
      data:setPixel(x, y, unpack(rgba))
    end
  end
end

local function developTriangle(data, box, bounds, rgba)
  local dx = box[1] > box[3] and -1 or 1
  for x = box[1] - bounds[1], box[3] - bounds[1], dx do
    local m = (box[2]-box[4]) / (box[1]-box[3])
    local ySlope = m*(x-box[1]+bounds[1]) + (box[2]-bounds[2])
    local dy = box[2] - bounds[2] > ySlope and -1 or 1
    for y = box[2] - bounds[2], ySlope, dy do
      if y < 0 or y >= bounds:getHeight() then break end
      data:setPixel(x, y, unpack(rgba))
    end
  end
end

function M.shoot(name, level, bounds)
  local padded = bounds  -- getPaddedBounds(bounds)
  local data = love.image.newImageData(padded:getWidth(), padded:getHeight())
  for k, v in pairs{
    rectangle = {developRectangle, {0, 0, 1, 1}},
    triangle = {developTriangle, {0, 0, 1, 1}},
    trellis = {developRectangle, {0.4, 0.4, 1, 1}},
  } do
    for _, boxes in entities[k].pairs(level) do
      for _, box in ipairs(boxes) do
        v[1](data, box, padded, v[2])
      end
    end
  end
  local file = assert(io.open("resources/" .. name .. ".png", "wb"))
  file:write(data:encode("png"):getString())
  file:close()
end

return M
