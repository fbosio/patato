local iter = require "engine.iterators"

local M = {}

function M.load(love, tagger)
  M.love = love
  M.love.graphics.setPointSize(5)
  M.tagger = tagger
end

local function drawMenu(components)
  local width, height = M.love.graphics.getDimensions()
  for _, menu in iter.menu(components) do
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

local function drawSprites(components, entityResources)
  local sortedEntities = getEntityNamesSortedByDepth(entityResources)
  for _, entityNames in pairs(sortedEntities) do
    for _, entityName in ipairs(entityNames) do
      local entityResources = entityResources[entityName]
      if entityResources then
        local entitySprites = entityResources.sprites
        local entityAnimations = entityResources.animations
        local entities = M.tagger.getIds(entityName)
        for _, entity in ipairs(entities) do
          local animation = (components.animation or {})[entity]
          local position = (components.position or {})[entity]
            local t = entityAnimations[animation.name]
            local quad = entitySprites.quads[t[animation.frame].sprite]
            local origin = entitySprites.origins[t[animation.frame].sprite]
            local x, y = position.x, position.y
            local scale = entitySprites.scale
            local direction = animation.flipX and -1 or 1
            M.love.graphics.draw(entitySprites.image, quad, x, y, 0,
                                 scale * direction, scale, origin.x, origin.y)
        end
      end
    end
  end
end

local function drawPositions(components)
  for entity, position in iter.position(components) do
    local x, y = position.x, position.y
    M.love.graphics.points{{x, y, 1, 0, 0, 1}}
    M.love.graphics.print({{1, 0, 0}, tostring(entity)}, x, y - 20)
  end
end

local function drawRectangle(position, box, r, g, b, a)
  local x, y = position.x - box.origin.x, position.y - box.origin.y
  M.love.graphics.setColor(r, g, b, a)
  M.love.graphics.rectangle("fill", x, y, box.width, box.height)
end

local function drawMousePosition()
  local mouseX, mouseY = love.mouse.getPosition()
  mouseX, mouseY = love.graphics.inverseTransformPoint(mouseX, mouseY)
  love.graphics.print(tostring(math.floor(mouseX)) .. ", "
                      .. tostring(math.floor(mouseY)),
                      mouseX + 10, mouseY - 10)
end

local function drawDebugElements(components)
  local rgba = {M.love.graphics.getColor()}

  for _, box, position in iter.collisionBox(components) do
    M.love.graphics.setColor(0, 0, 1)
    local x, y = position.x - box.origin.x, position.y - box.origin.y
    M.love.graphics.rectangle("line", x, y, box.width, box.height)
  end

  for _, collideable, box, position in iter.collideable(components) do
    M.love.graphics.setColor(0, 0, 1, 0.3)
    local x, y = position.x - box.origin.x, position.y - box.origin.y
    if box.height == 0 then
      M.love.graphics.line(x, y, x + box.width, y)
    elseif collideable.normalPointingUp ~= nil
        and collideable.rising ~= nil then
      local y1 = collideable.normalPointingUp and y+box.height or y
      local x3 = ((collideable.normalPointingUp and not collideable.rising)
                  or (not collideable.normalPointingUp and collideable.rising))
                  and x or x+box.width
      local y3 = collideable.normalPointingUp and y or y+box.height
      M.love.graphics.polygon("fill", {x, y1, x + box.width, y1, x3, y3})
    else
      M.love.graphics.rectangle("fill", x, y, box.width, box.height)
    end
  end

  for _, isTrellis, box, position in iter.trellis(components) do
    if isTrellis then
      drawRectangle(position, box, 0.4, 0.4, 1, 0.3)
    end
  end

  for _, isCollectable, box, position in iter.collectable(components) do
    if isCollectable then
      drawRectangle(position, box, 0.4, 1, 0.4, 0.3)
    end
  end
  
  M.love.graphics.setColor(rgba)
  drawPositions(components)
  drawMousePosition()
end

function M.draw(gameState, entityResources, release)
  if gameState.inMenu then
    drawMenu(gameState.components)
  else
    drawSprites(gameState.components, entityResources)
    if not release then
      drawDebugElements(gameState.components)
    end
  end
end

return M