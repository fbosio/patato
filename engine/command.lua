local M = {}

function M.load(entityTagger, hid, components)
  M.entityTagger = entityTagger
  M.hid = hid
  M.components = components
end

local kinds = {"hold", "press", "release"}

function M.set(entityName, input, callback, kind)
  local existentKind = false
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

  M.components.controllable = M.components.controllable or {}
  local controllable = M.components.controllable
  local entities = M.entityTagger.getIds(entityName)
  for _, entity in ipairs(entities) do
    controllable[entity] = controllable[entity] or {}
    controllable[entity][kind] = controllable[entity][kind] or {}
    controllable[entity][kind][input] = false
  end
end

-- Old code
-- Check that all values of table t1 are in table t2.
local function isIncluded(t1, t2)                                                                   
  for _, v1 in ipairs(t1) do                                                                        
    local hasValue = false                                                                          
    for _, v2 in ipairs(t2) do                                                                      
      if v1 == v2 then                                                                              
        hasValue = true                                                                             
        break                                                                                       
      end                                                                                           
    end                                                                                             
    if not hasValue then                                                                            
      return false                                                                                  
    end                                                                                             
  end                                                                                               
  return true                                                                                       
end

local mt = {
  __eq = function (a, b)
    return not a.release == not b.release and not a.oneShot == not b.oneShot
      and isIncluded(a.input, b.input) and isIncluded(b.input, a.input)
  end
}

function M.new(args)
  local newCommand = {
    release = args.release,
    oneShot = args.oneShot,
    input = type(args.input) == "table" and args.input or {args.input}
  }
  setmetatable(newCommand, mt)
  return newCommand
end

return M