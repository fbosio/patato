local M = {}

local function buildSprites(entitySprites)
  local sprites = {
    image = M.love.graphics.newImage(entitySprites.image),
    scale = entitySprites.scale or 1
  }
  if entitySprites.tiled then
    sprites.image:setWrap("repeat")
    sprites.quads = {
      M.love.graphics.newQuad(0, 0, M.love.graphics.getWidth(),
                              M.love.graphics.getHeight(),
                              sprites.image:getDimensions())
    }
    sprites.origins = {
      {x = 0, y = 0}
    }
  elseif entitySprites.quads then
    local quads = {}
    local origins = {}
    local spritesImage = sprites.image
    for _, quadData in ipairs(entitySprites.quads) do
      local x, y, w, h, originX, originY = unpack(quadData)
      quads[#quads+1] = M.love.graphics.newQuad(x, y, w, h,
                                                spritesImage:getDimensions())
      origins[#origins+1] = {x = originX, y = originY}
    end
    sprites.quads = quads
    sprites.origins = origins
  end
  sprites.depth = entitySprites.depth or 1
  return sprites
end

local function buildAnimations(entityAnimations)
  local animations = {}
  for name, entityAnimation in pairs(entityAnimations) do
    local animation = {
      frames = {},
      durations = {},
      looping = false
    }
    for j, v in ipairs(entityAnimation) do
      if type(v) == "boolean" then
        animation.looping = v
        break
      end
      local i = math.ceil(j/2)
      if j % 2 == 0 then
        animation.durations[i] = v
      else
        animation.frames[i] = v
      end
    end
    animations[name] = animation
  end
  return animations
end

function M.load(love, config)
  M.love = love

  local loaded = {}

  for entityName, entityData in pairs(config.entities) do
    local entityResources = entityData.resources or {}
    if entityResources.sprites then
      assert(entityResources.sprites.image,
             "Entity " .. entityName .. " has resources but no image declared"
             .. " in config.lua")
      loaded[entityName] = loaded[entityName] or {}
      loaded[entityName].sprites = buildSprites(entityResources.sprites)
    end
    if entityResources.animations then
      loaded[entityName] = loaded[entityName] or {}
      loaded[entityName].animations =
        buildAnimations(entityResources.animations)
    end
  end

  return loaded
end

return M