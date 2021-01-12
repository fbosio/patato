function love.conf(t)
  for k, _ in pairs(t.modules) do t[k] = false end  -- disable all modules
  -- except the following ones
  t.modules.event = true
  t.modules.image = true
end
