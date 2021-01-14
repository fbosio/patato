local M = {}

function M.load()
  local t = {}
  setmetatable(t, {
    __index = function ()
      return function () end
    end
  })
  return t
end

return M
