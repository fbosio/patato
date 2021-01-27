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
      local frameSfx
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
            frameSfx = cel.data
          end
        end
      end
      -- Get sprite origin
      local originCel = originLayer:cel(frameNumber)
      if not originCel then
        print("No cel in " .. tostring(frameNumber) .. "."
              .. " Using (0, 0) as origin.")
        origin.x, origin.y = 0, 0
      else
        origin.x = originCel.position.x - frameRectangle.x
        origin.y = originCel.position.y - frameRectangle.y
      end
      local tagFrames = tagsMap[tag.name] or {}
      tagFrames[#tagFrames+1] = {
        spriteNumber = uniqueSpriteNumber,
        sfx = frameSfx
      }
      tagsMap[tag.name] = tagFrames
      -- Add to the sprites buffer only data from unique frames
      if isNewFrameData then
        sprBuffer[#sprBuffer+1] = "\t\t{"
          .. tostring(x) .. ", "
          .. tostring(y) .. ", "
          .. tostring(frameRectangle.width) .. ", "
          .. tostring(frameRectangle.height) .. ", "
          .. tostring(origin.x) .. ", "
          .. tostring(origin.y)
        .. "}"
        spriteNumber = spriteNumber + 1
        x = x + frameRectangle.width + innerPadding * 2
      end
    end
    x = innerPadding
    y = y + frameRectangle.height + innerPadding * 2
  end
end

-- Build animations buffer using tags map builded before
local animBuffer = {}
for tagName, tagFrames in pairs(tagsMap) do
  local animDataBuffer = {}
  for _, frameData in ipairs(tagFrames) do
    local frameNumber = frameData.spriteNumber
    local newAnimData = "\n\t\t{"
      .. "sprite = " .. frameNumber .. ", "
      .. "duration = " .. spr.frames[frameNumber].duration
    if frameData.sfx ~= "" then
      newAnimData = newAnimData .. ', sfx = "' .. frameData.sfx .. '"'
    end
    newAnimData = newAnimData .. "}"
    animDataBuffer[#animDataBuffer+1] = newAnimData
  end
  animBuffer[#animBuffer+1] = "\t" .. tagName .. " = {"
    .. table.concat(animDataBuffer, ", ")
  .. "\n\t}"
end

-- Write output file
local path, dir, title =
  spr.filename:match("^(.+[/\\])(.+[/\\])(.-).([^.]*)$")
do
  local sprOutput = "{\n" .. table.concat(sprBuffer, ",\n") .. "\n\t}"
  local animOutput = "{\n" .. table.concat(animBuffer, ",\n") .. "\n}"
  local output = "local M = {}\nM.sprites = {\n"
                 .. "\timage = \"resources/images/" .. title .. ".png\",\n"
                 .. "\tquads = " .. sprOutput .. "\n}\n"
                 .. "M.animations = " .. animOutput .. "\nreturn M\n"
  local file = assert(io.open(path .. "metadata/" .. title .. ".lua", "w+"))
  file:write(output)
  file:close()
end

app.command.ExportSpriteSheet{
  ui = false,
  type = SpriteSheetType.ROWS,
  textureFilename = path .. dir .. title .. ".png",
  innerPadding = innerPadding,
  trim = true,
  splitTags = true,
  mergeDuplicates = true
}

originLayer.isVisible = wasOriginLayerVisible
