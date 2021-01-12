local chunk = require "chunk"

local M = {}

local function newEntityGenerator(patterns)
  -- Find entities from the given patterns
  if type(patterns) == "string" then patterns = {patterns} end
  local entities = {}
  for _, pattern in ipairs(patterns) do
    for entityName in string.gmatch(chunk.getValue("entities"), pattern) do
      entities[#entities+1] = entityName
    end
  end
  -- Return a stateless "iterator" (it is actually a generator, but whatever)
  return function (t, k)
    local data
    repeat
      k, data = next(t, k)
      if not k then return nil end
      for _, collideable in ipairs(entities) do
        if k == collideable then
          return k, data
        end
      end
    until not k
  end
end

local patterns = {
  messaging = {
    '([_%a][_%w]*)%s*=%s*{[^{]*collideable%s*=%s*%b"".-}',
    '([_%a][_%w]*)%s*=%s*{[^{]*flags%s*=%s*{[^}]*"trellis"[^}]*}'
  },
  rectangle = {
    '([_%a][_%w]*)%s*=%s*{[^{]*collideable%s*=%s*"rectangle".-}',
    '([_%a][_%w]*)%s*=%s*{[^{]*flags%s*=%s*{[^}]*"trellis"[^}]*}'
  },
  triangle = '([_%a][_%w]*)%s*=%s*{[^{]*collideable%s*=%s*"triangle".-}'
}
for entityType, pattern in pairs(patterns) do
  M[entityType] = {
    pairs = function (t)
      return newEntityGenerator(pattern), t
    end
  }
end

return M
