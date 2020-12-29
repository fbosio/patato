local M = {}

function M.load(love, tagger)
  M.love = love
  M.love.graphics.setPointSize(5)
  M.tagger = tagger
end

function M.draw(components, inMenu, resources)
  if inMenu then
    local width, height = M.love.graphics.getDimensions()

    for _, menu in pairs(components.menu) do
      for i, option in ipairs(menu.options) do
        local font = M.love.graphics.getFont()
        local blue = menu.selected == i and 0 or 1
        M.love.graphics.print({{1, 1, blue}, option},
                              (width-font:getWidth(option))/2,
                              (i-0.5)*height/#menu.options)
      end
    end

  else
    for entity, box in pairs(components.collisionBox or {}) do
      local position = components.position[entity]
      local x, y = position.x - box.origin.x, position.y - box.origin.y
      if box.height == 0 then
        M.love.graphics.line(x, y, x+box.width, y)
      else
        local collideable = (components.collideable or {})[entity] or {}
        if collideable.normalPointingUp ~= nil
            and collideable.rising ~= nil then
          local y1 = collideable.normalPointingUp and y+box.height or y
          local x3 = ((collideable.normalPointingUp and not collideable.rising)
                      or (not collideable.normalPointingUp and collideable.rising))
                     and x or x+box.width
          local y3 = collideable.normalPointingUp and y or y+box.height
          M.love.graphics.polygon("fill", {x, y1, x+box.width, y1, x3, y3})
        else
          M.love.graphics.rectangle("fill", x, y, box.width, box.height)
        end
      end
    end

    if resources.sprites then
      for entity, animation in pairs(components.animation or {}) do
        local position = (components.position or {})[entity]
        local entityName = M.tagger.getName(entity)
        local entityAnimations = resources.animations[entityName]
        local t = entityAnimations[animation.name]
        local sprite = resources.sprites[t.frames[animation.frame]]
        local x, y = position.x, position.y
        local scale = resources.spriteScale
        love.graphics.draw(resources.spriteSheet, sprite.quad, x, y, 0,
                           scale, scale, sprite.origin.x, sprite.origin.y)
      end
    end

    for entity, position in pairs(components.position or {}) do
      local x, y = position.x, position.y
      M.love.graphics.points{{x, y, 1, 0, 0, 1}}
      M.love.graphics.print({{1, 0, 0}, tostring(entity)}, x, y - 50)
    end
  end
end

return M