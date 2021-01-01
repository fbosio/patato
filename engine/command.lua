local M = {}

function M.new(args)
  return {
    release = args.release,
    oneShot = args.oneShot,
    keys = args.keys or {args.key}
  }
end

return M