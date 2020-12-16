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

local function doActionIfKeyIsDown(keys, inputs, velocity, impulseSpeed)
  local pressed = {}

  for virtualKey, physicalKey in pairs(keys) do
    if M.love.keyboard.isDown(physicalKey) then
      pressed[#pressed+1] = virtualKey
      for entity, input in pairs(inputs) do
        for inputName, inputKey in pairs(input) do
          if inputKey == virtualKey then
            actions[inputName](velocity[entity], impulseSpeed[entity])
          end
        end
      end
    end
  end

  return pressed
end

local function doOmissionIfKeyIsUp(pressed, inputs, velocity)
  for omittedActions, omission in pairs(omissions) do
    local mustOmit = true

    for _, omittedAction in ipairs(omittedActions) do
      for _, pressedKey in ipairs(pressed) do
        for _, input in pairs(inputs) do
          for inputAction, inputKey in pairs(input) do
            if inputKey == pressedKey and inputAction == omittedAction then
              mustOmit = false
            end
          end
        end
      end
    end

    if mustOmit then
      for entity, input in pairs(inputs) do
        for inputAction, _ in pairs(input) do
          for _, omittedAction in ipairs(omittedActions) do
            if omittedAction == inputAction then
              omission(velocity[entity])
            end
          end
        end
      end
    end
  end
end

function M.load(love)
  M.love = love
end

function M.update(keys, inputs, velocity, impulseSpeed)
  inputs = inputs or {}

  local pressed = doActionIfKeyIsDown(keys, inputs, velocity, impulseSpeed)
  doOmissionIfKeyIsUp(pressed, inputs, velocity)
end

return M
