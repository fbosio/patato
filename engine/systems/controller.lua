local M = {}

local actions = {
  walkLeft = function (v, s) v.x = -s.walk end,
  walkRight = function (v, s) v.x = s.walk end,
  walkUp = function (v, s) v.y = -s.walk end,
  walkDown = function (v, s) v.y = s.walk end,
}
setmetatable(actions, {
  __index = function ()
    return function () end
  end
})

local omissions = {
  [{"walkLeft", "walkRight"}] = function (v) v.x = 0 end,
  [{"walkUp", "walkDown"}] = function (v) v.y = 0 end,
}

local function doActionIfKeyIsDown(keys, input, velocity, impulseSpeed)
  local pressed = {}

  for virtualKey, physicalKey in pairs(keys) do
    if M.love.keyboard.isDown(physicalKey) then
      pressed[#pressed+1] = virtualKey
      for inputName, inputKey in pairs(input) do
        if inputKey == virtualKey then
          actions[inputName](velocity, impulseSpeed)
        end
      end
    end
  end

  return pressed
end

local function doOmissionIfKeyIsUp(pressed, input, velocity)
  for omittedActions, omission in pairs(omissions) do
    local mustOmit = true

    for inputAction, inputKey in pairs(input) do
      for _, omittedAction in ipairs(omittedActions) do
        for _, pressedKey in ipairs(pressed) do
          if inputKey == pressedKey and omittedAction == inputAction then
            mustOmit = false
          end
        end
      end
    end

    if mustOmit then
      for inputAction, _ in pairs(input) do
        for _, omittedAction in ipairs(omittedActions) do
          if omittedAction == inputAction then
            omission(velocity)
          end
        end
      end
    end
  end
end

function M.load(love)
  M.love = love
end

function M.update(keys, inputs, velocities, impulseSpeeds)
  inputs = inputs or {}

  for entity, input in pairs(inputs) do
    local velocity = velocities[entity]
    local impulseSpeed = impulseSpeeds[entity]
    local pressed = doActionIfKeyIsDown(keys, input, velocity, impulseSpeed)
    doOmissionIfKeyIsUp(pressed, input, velocity)
  end
end

return M
