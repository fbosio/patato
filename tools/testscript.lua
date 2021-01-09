local spr = app.activeSprite
if not spr then
  app.alert("No active sprite")
  return
elseif #spr.tags == 0 then
  app.alert("No tags")
  return
end
-- #spr.layers is always greater than zero: no checking needed
local resetOriginLayer, originLayer
for _, layer in ipairs(spr.layers) do
  if string.find(string.lower(layer.name), "^origins?$") then
    originLayer = layer
    local wasVisible = layer.isVisible
    resetOriginLayer = function ()
      layer.isVisible = wasVisible
    end
    layer.isVisible = false
    break
  end
end
if not resetOriginLayer then
  app.alert('No "Origin" layer')
  return
end

-- Build sprites buffer
local spritesBuffer = {}
local origin = {x = 0, y = 0}
local borderPadding = 1
local spacing = 1
local x, y = borderPadding, borderPadding
local frameRectangle = Rectangle()
for _, tag in ipairs(spr.tags) do
  frameRectangle.x, frameRectangle.y = 0, 0
  frameRectangle.width = 0
  for frameNumber = tag.fromFrame.frameNumber, tag.toFrame.frameNumber do
    if frameNumber == tag.fromFrame.frameNumber then
      local cel = originLayer:cel(frameNumber)
      origin.x = cel.position.x
      origin.y = cel.position.y
    end
    for _, layer in ipairs(spr.layers) do
      if layer ~= originLayer then
        local cel = layer:cel(frameNumber)
        frameRectangle = frameRectangle:union(cel.bounds)
      end
    end
    spritesBuffer[#spritesBuffer+1] = "\t{"
      .. tostring(x) .. ", "
      .. tostring(y) .. ", "
      .. tostring(frameRectangle.width) .. ", "
      .. tostring(frameRectangle.height) .. ", "
      .. tostring(origin.x) .. ", "
      .. tostring(origin.y)
    .. "}"
    x = x + frameRectangle.width + spacing
  end
  y = y + frameRectangle.height + spacing
end

-- Write output file
local spritesOutput = "{\n" .. table.concat(spritesBuffer, ",\n") .. "\n}"
local output = "local M\nM.sprites = " .. spritesOutput .. "\nreturn M\n"
local file = assert(io.open("resources.lua", "w+"))
file:write(output)
file:close()

resetOriginLayer()
