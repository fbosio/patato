local M = {}

function M.new(args)
  local newCommand = {
    release = args.release,
    oneShot = args.oneShot,
    key = args.key
  }
  setmetatable(newCommand, {
    __eq = function (a, b)
      return a.release == b.release and a.oneShot == b.oneShot
             and a.key == b.key
    end
  })

  return newCommand
end

return M