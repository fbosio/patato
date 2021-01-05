local M = {}

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
      and isIncluded(a.keys, b.keys) and isIncluded(b.keys, a.keys)
  end
}

function M.new(args)
  local newCommand = {
    release = args.release,
    oneShot = args.oneShot,
    keys = args.keys or {args.key}
  }
  setmetatable(newCommand, mt)
  return newCommand
end

return M