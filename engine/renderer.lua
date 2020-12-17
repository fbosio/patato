local M = {}

function M.load(love)
  M.love = love
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
    for _, position in pairs(st.position or {}) do
      M.love.graphics.points({position.x, position.y})
    end
  end
end

return M