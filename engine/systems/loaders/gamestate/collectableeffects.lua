local M = {}

function M.load()
  return setmetatable({}, {
    __index = function (_, k)
      error('Entity "' .. k .. '" has no collectable effect assigned to it',
            0)
    end
  })
end

return M
