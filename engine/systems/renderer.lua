local M = {}

function M.load(love, tagger)
  M.love = love
  M.love.graphics.setPointSize(5)
  M.tagger = tagger
end

local function drawMenu(components)
  local width, height = M.love.graphics.getDimensions()
  for _, menu in pairs(components.menu) do
    for i, option in ipairs(menu.options) do
      local font = M.love.graphics.getFont()
      M.love.graphics.print({{1, 1, menu.selected == i and 0 or 1}, option},
                            (width-font:getWidth(option))/2,
                            (i-0.5)*height/#menu.options)
    end
  end
end

local function getEntityNamesSortedByDepth(resources)
  local entityNames = {}
  local depths = {}
  for entityName, resource in pairs(resources or {}) do
    local depth = (resource.sprites or {}).depth
    local equallyDepthEntities = entityNames[depth] or {}
    equallyDepthEntities[#equallyDepthEntities+1] = entityName
    entityNames[depth] = equallyDepthEntities
    depths[#depths+1] = depth
  end
  table.sort(depths, function (a, b) return a > b end)
  local sorted = {}
  for _, depth in ipairs(depths) do
    sorted[#sorted+1] = entityNames[depth]
  end
  return sorted
end

local function drawSprites(components, resources)
  local sortedEntities = getEntityNamesSortedByDepth(resources)
  for _, entityNames in pairs(sortedEntities) do
    for _, entityName in ipairs(entityNames) do
      local entityResources = resources[entityName]
      if entityResources then
        local entitySprites = entityResources.sprites
        local entityAnimations = entityResources.animations
        local entities = M.tagger.getIds(entityName)
        for _, entity in ipairs(entities) do
          local animation = (components.animation or {})[entity]
          local position = (components.position or {})[entity]
            local t = entityAnimations[animation.name]
            local quad = entitySprites.quads[t.frames[animation.frame]]
            local origin = entitySprites.origins[t.frames[animation.frame]]
            local x, y = position.x, position.y
            local scale = entitySprites.scale
            love.graphics.draw(entitySprites.image, quad, x, y, 0, scale,
                               scale, origin.x, origin.y)
        end
      end
    end
  end
end

local function drawPositions(positions)
  for entity, position in pairs(positions or {}) do
    local x, y = position.x, position.y
    M.love.graphics.points{{x, y, 1, 0, 0, 1}}
    M.love.graphics.print({{1, 0, 0}, tostring(entity)}, x, y - 20)
  end
end

local function drawDebugElements(components)
  local rgba = {love.graphics.getColor()}
  for entity, box in pairs(components.collisionBox or {}) do
    love.graphics.setColor(0, 0, 1, 0.3)
    local position = components.position[entity]
    local x, y = position.x - box.origin.x, position.y - box.origin.y
    if box.height == 0 then
      M.love.graphics.line(x, y, x + box.width, y)
    else
      local collideable = (components.collideable or {})[entity] or {}
      if collideable.normalPointingUp ~= nil
          and collideable.rising ~= nil then
        local y1 = collideable.normalPointingUp and y+box.height or y
        local x3 = ((collideable.normalPointingUp and not collideable.rising)
                    or (not collideable.normalPointingUp and collideable.rising))
                   and x or x+box.width
        local y3 = collideable.normalPointingUp and y or y+box.height
        M.love.graphics.polygon("fill", {x, y1, x + box.width, y1, x3, y3})
      else
        if (components.trellis or {})[entity] then
          love.graphics.setColor(0.4, 0.4, 1, 0.3)
        elseif (components.collectable or {})[entity] then
          love.graphics.setColor(0.4, 1, 0.4, 0.3)
        end
        M.love.graphics.rectangle("fill", x, y, box.width, box.height)
      end
    end
  end

  love.graphics.setColor(rgba)
  drawPositions(components.position)
end

function M.draw(components, inMenu, resources, release)
  if inMenu then
    drawMenu(components)
  else
    drawSprites(components, resources)
    if not release then
      drawDebugElements(components)
    end
  end
end

return M