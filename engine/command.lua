local M = {}

function M.load(hid, components)
  M.hid = hid
  M.components = components
end

function M.set(entityName, input, callback, kind)
  local existentKind = false
  local kinds = {"hold", "press", "release"}
  for _, v in ipairs(kinds) do
    if v == kind then
      existentKind = true
      break
    end
  end
  assert(existentKind, "Unexpected command type \"" .. kind .. "\"")
  M.hid.commands = M.hid.commands or {}
  local commands = M.hid.commands
  commands[kind] = commands[kind] or {}
  commands[kind][entityName] = commands[kind][entityName] or {}
  commands[kind][entityName][input] = callback
end

function M.update(entity, name)
  if not M.components then return end
  local controllable = M.components.controllable
  for kind, t in pairs(M.hid.commands) do
    if t[name] then
      for input, _ in pairs(t[name]) do
        assert(controllable[entity], "Entity \"" .. name .. "\" is not "
                .. "controllable but a command is being set for it")
        controllable[entity][kind] = controllable[entity][kind] or {}
        controllable[entity][kind][input] = false
      end
    end
  end
end

return M
