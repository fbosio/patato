local M = {}

local function loadSounds(configSounds)
  local sounds
  for stem, name in pairs((configSounds or {}).sfx or {}) do
    sounds = sounds or {}
    sounds.sfx = sounds.sfx or {}
    sounds.sfx[stem] = M.love.audio.newSource(name, "static")
  end
  for stem, name in pairs((configSounds or {}).bgm or {}) do
    sounds = sounds or {}
    sounds.bgm = sounds.bgm or {}
    sounds.bgm[stem] = M.love.audio.newSource(name, "stream")
  end
  return sounds
end

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
    local animation = {}
    for k, v in ipairs(entityAnimation) do
      animation[k] = v
    end
    animations[name] = animation
  end
  return animations
end

local function loadEntities(configEntities)
  local entities
  for entityName, entityData in pairs(configEntities or {}) do
    entities = entities or {}
    local entityResources = entityData.resources or {}
    local sprites = entityResources.sprites
    local animations = entityResources.animations
    local loadedEntity = {}
    if sprites then
      assert(entityResources.sprites.image,
             "Entity " .. entityName .. " has resources but no image declared"
             .. " in config.lua")
      loadedEntity.sprites = buildSprites(entityResources.sprites)
    end
    if animations then
      loadedEntity.animations = buildAnimations(entityResources.animations)
    end
    entities[entityName] = (sprites or animations) and loadedEntity
  end
  return entities
end

function M.load(love, config)
  M.love = love

  return {
    sounds = loadSounds(config.sounds),
    entities = loadEntities(config.entities)
  }
end

return M
