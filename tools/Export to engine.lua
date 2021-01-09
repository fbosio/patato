local spr = app.activeSprite
if not spr then
  app.alert("No active sprite")
  return
elseif #spr.tags == 0 then
  app.alert("No tags")
  return
end
-- #spr.layers is always greater than zero: no checking needed
local originLayer, wasOriginLayerVisible
for _, layer in ipairs(spr.layers) do
  if layer.name:lower():find("^origins?$") then
    originLayer = layer
    wasOriginLayerVisible = layer.isVisible
    layer.isVisible = false
    break
  end
end
if not originLayer then
  app.alert('No "Origin" layer')
  return
end

-- Build sprites buffer
local sprBuffer = {}
local tagsMap = {}
do
  local origin = {x = 0, y = 0}
  local borderPadding = 1
  local spacing = 1
  local x, y = borderPadding, borderPadding
  local frameRectangle = Rectangle()
  local celImages = {}
  for _, tag in ipairs(spr.tags) do
    frameRectangle.x, frameRectangle.y = 0, 0
    frameRectangle.width = 0
    for frameNumber = tag.fromFrame.frameNumber, tag.toFrame.frameNumber do
      if frameNumber == tag.fromFrame.frameNumber then
        local cel = originLayer:cel(frameNumber)
        if not cel then
          app.alert("No cel in " .. tostring(frameNumber) .. "."
                    .. "Using (0, 0) as origin.")
          origin.x, origin.y = 0, 0
        else
          origin.x, origin.y = cel.position.x, cel.position.y
        end
      end
      -- Check if the frame data was already added
      local isNewFrameData = false
      for _, layer in ipairs(spr.layers) do
        if layer ~= originLayer then
          local cel = layer:cel(frameNumber)
          if cel then
            local isNewCelData = true
            for _, celImage in ipairs(celImages) do
              if celImage:isEqual(cel.image) then
                isNewCelData = false
                break
              end
            end
            if isNewCelData or #celImages == 0 then
              frameRectangle = frameRectangle:union(cel.bounds)
              isNewFrameData = true
              celImages[#celImages+1] = cel.image
            end
          end
        end
      end
      -- Add to the sprites buffer only data from unlinked frames
      if isNewFrameData then
        local tagFrameNumbers = tagsMap[tag.name] or {}
        tagFrameNumbers[#tagFrameNumbers+1] = frameNumber
        tagsMap[tag.name] = tagFrameNumbers
        sprBuffer[#sprBuffer+1] = "\t{"
          .. tostring(x) .. ", "
          .. tostring(y) .. ", "
          .. tostring(frameRectangle.width) .. ", "
          .. tostring(frameRectangle.height) .. ", "
          .. tostring(origin.x) .. ", "
          .. tostring(origin.y)
        .. "}"
        x = x + frameRectangle.width + spacing
      end
    end
    y = y + frameRectangle.height + spacing
  end
end

-- Build animations buffer
local animBuffer = {}
for tagName, frameNumbers in pairs(tagsMap) do
  local animDataBuffer = {}
  for _, frameNumber in ipairs(frameNumbers) do
    animDataBuffer[#animDataBuffer+1] = frameNumber
    animDataBuffer[#animDataBuffer+1] = spr.frames[frameNumber].duration
  end
  local suffixIndex = tagName:find("_loop")
  local nameWithoutSuffix = tagName:sub(1, suffixIndex and suffixIndex - 1)
  local looping = false
  if nameWithoutSuffix ~= tagName then
    tagName = nameWithoutSuffix
    looping = true
  end
  animBuffer[#animBuffer+1] = "\t" .. tagName .. " = {"
    .. table.concat(animDataBuffer, ", ") .. ", " .. tostring(looping)
  .. "}"
end

-- Write output file
local path, title = spr.filename:match("^(.+[/\\])(.-).([^.]*)$")
do
  local sprOutput = "{\n" .. table.concat(sprBuffer, ",\n") .. "\n}"
  local animOutput = "{\n" .. table.concat(animBuffer, ",\n") .. "\n}"
  local output = "local M\nM.sprites = " .. sprOutput
                 .. "\nM.animations = " .. animOutput .. "\nreturn M\n"
  local file = assert(io.open(path .. "/resources.lua", "w+"))
  file:write(output)
  file:close()
end

app.command.ExportSpriteSheet{
  ui = false,
  type = SpriteSheetType.ROWS,
  textureFilename = path .. "/" .. title .. ".png",
  innerPadding = 1,
  trim = true,
  splitTags = true,
  mergeDuplicates = true
}

originLayer.isVisible = wasOriginLayerVisible
