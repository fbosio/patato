local messagingEntities = require "entities".messaging
local getCoordinates = require "box".getCoordinates

local M = {}

-- Extend box1 in order to contain box2
local function extend(box1, box2)
  local  x1, y1, x2, y2 = unpack(getCoordinates(box2))
  if not box1[1] or box1[1] > x1 then box1[1] = x1 end
  if not box1[2] or box1[2] > y1 then box1[2] = y1 end
  if not box1[3] or box1[3] < x2 then box1[3] = x2 end
  if not box1[4] or box1[4] < y2 then box1[4] = y2 end
end

function M.measure(level)
  local boundaries = {}
  for _, data in messagingEntities.pairs(level) do
    if type(data[1]) == "table" then
      for _, boundary in ipairs(data) do
        extend(boundaries, boundary)
      end
    else
      extend(boundaries, data)
    end
  end
  boundaries.getWidth = function (self)
    return math.abs(self[3] - self[1])
  end
  boundaries.getHeight = function (self)
    return math.abs(self[4] - self[2])
  end
  return boundaries
end

return M
