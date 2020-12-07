local M = {}

local actions = {
  left = function (v, s) v.x = -s.walk end,
  right = function (v, s) v.x = s.walk end,
}
setmetatable(actions, {
  __index = function (t, k)
    if not rawget(t, k) then
      return function () end
    else
      return t[k]
    end
  end
})

local omissions = {
  [{"left", "right"}] = function (v) v.x = 0 end,
  [{"up", "down"}] = function (v) v.y = 0 end,
}

function M.update(keys, inputs, velocity, impulseSpeed)
  local pressed = {}

  for virtualKey, physicalKey in pairs(keys) do
    if love.keyboard.isDown(physicalKey) then
      pressed[#pressed+1] = virtualKey
      for entity, input in pairs(inputs) do
        actions[virtualKey](velocity[entity], impulseSpeed[entity])
      end
    end
  end

  for omittedKeys, omission in pairs(omissions) do
    local mustOmit = true

    for __, omittedKey in ipairs(omittedKeys) do
      for __, pressedKey in ipairs(pressed) do
        if pressedKey == omittedKey then
          mustOmit = false
        end
      end
    end

    if mustOmit then
      for entity, input in pairs(inputs) do
        omission(velocity[entity])
      end
    end
  end
end

return M
