if love then
  M = love
else
  M = {graphics={}}
  function M.graphics.getDimensions()
    return 800, 600
  end
end

return M
