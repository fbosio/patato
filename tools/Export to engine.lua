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

-- Build sprites buffer and tags map for animations buffer
local sprBuffer = {}
local tagsMap = {}
local innerPadding = 1
do
  local origin = {x = 0, y = 0}
  local x, y = innerPadding, innerPadding
  local uniqueCelsSprNumber = {}
  local spriteNumber = 1
  local frameRectangle = Rectangle()
  for _, tag in ipairs(spr.tags) do
    for frameNumber = tag.fromFrame.frameNumber, tag.toFrame.frameNumber do
      frameRectangle.x, frameRectangle.y = 0, 0
      frameRectangle.width = 0
      -- Check if the frame data was already added
      local isNewFrameData = false
      local uniqueSpriteNumber = spriteNumber
      for _, layer in ipairs(spr.layers) do
        if layer ~= originLayer then
          local cel = layer:cel(frameNumber)
          if cel then
            local isNewCelData = true
            if not isNewFrameData then
              for uniqueCel, celSprNumber in pairs(uniqueCelsSprNumber) do
                if uniqueCel.image:isEqual(cel.image)
                    and uniqueCel.position.x == cel.position.x
                    and uniqueCel.position.y == cel.position.y then
                  isNewCelData = false
                  uniqueSpriteNumber = celSprNumber
                  break
                end
              end
            end
            frameRectangle = frameRectangle.isEmpty
                             and cel.bounds
                             or frameRectangle:union(cel.bounds)
            if isNewCelData then
              isNewFrameData = true
              uniqueCelsSprNumber[cel] = spriteNumber
              uniqueSpriteNumber = spriteNumber
            end
          end
        end
      end
      -- Get sprite origin
      local cel = originLayer:cel(frameNumber)
      if not cel then
        print("No cel in " .. tostring(frameNumber) .. "."
              .. " Using (0, 0) as origin.")
        origin.x, origin.y = 0, 0
      else
        origin.x = cel.position.x - frameRectangle.x
        origin.y = cel.position.y - frameRectangle.y
      end
      local tagSpriteNumbers = tagsMap[tag.name] or {}
      tagSpriteNumbers[#tagSpriteNumbers+1] = uniqueSpriteNumber
      tagsMap[tag.name] = tagSpriteNumbers
      -- Add to the sprites buffer only data from unique frames
      if isNewFrameData then
        sprBuffer[#sprBuffer+1] = "\t{"
          .. tostring(x) .. ", "
          .. tostring(y) .. ", "
          .. tostring(frameRectangle.width) .. ", "
          .. tostring(frameRectangle.height) .. ", "
          .. tostring(origin.x) .. ", "
          .. tostring(origin.y)
        .. "}"
        spriteNumber = spriteNumber + 1
        x = x + frameRectangle.width + innerPadding
      end
    end
    x = innerPadding
    y = y + frameRectangle.height + innerPadding
  end
end

-- Build animations buffer using tags map builded before
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
  local output = "local M = {}\nM.sprites = " .. sprOutput
                 .. "\nM.animations = " .. animOutput .. "\nreturn M\n"
  local file = assert(io.open(path .. title .. ".lua", "w+"))
  file:write(output)
  file:close()
end

app.command.ExportSpriteSheet{
  ui = false,
  type = SpriteSheetType.ROWS,
  textureFilename = path .. "/" .. title .. ".png",
  innerPadding = innerPadding,
  trim = true,
  splitTags = true,
  mergeDuplicates = true
}

originLayer.isVisible = wasOriginLayerVisible
