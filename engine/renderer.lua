local M = {}

function M.load(love, tagger)
  M.love = love
  M.love.graphics.setPointSize(5)
  M.tagger = tagger
end

function M.draw(engine)
  local st = engine.gameState

  if engine.inMenu then
    local width, height = M.love.graphics.getDimensions()

    for _, menu in pairs(st.menu) do
      for i, option in ipairs(menu.options) do
        local font = M.love.graphics.getFont()
        local blue = menu.selected == i and 0 or 1
        M.love.graphics.print({{1, 1, blue}, option},
                              (width-font:getWidth(option))/2,
                              (i-0.5)*height/#menu.options)
      end
    end

  else
    for _, box in pairs(st.collisionBox or {}) do
      M.love.graphics.rectangle("fill", box.x, box.y, box.width, box.height)
    end

    if engine.sprites then
      for entity, animation in pairs(st.animation or {}) do
        local position = (st.position or {})[entity]
        local x, y = position.x, position.y
        local _, t = next(engine.animations[M.tagger.getName(entity)])
        local sprite = engine.sprites[t.frames[animation.frame]]
        love.graphics.draw(engine.spriteSheet, sprite.quad, x, y)
      end
    end
    
    for entity, position in pairs(st.position or {}) do
      local x, y = position.x, position.y
      M.love.graphics.points{{x, y, 1, 0, 0, 1}}
      M.love.graphics.print({{1, 0, 0}, tostring(entity)}, x, y - 50)
    end
  end
end

return M