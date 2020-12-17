local M = {}

local actions = {
  walkLeft = function (t) t.velocity.x = -t.walkSpeed end,
  walkRight = function (t) t.velocity.x = t.walkSpeed end,
  walkUp = function (t) t.velocity.y = -t.walkSpeed end,
  walkDown = function (t) t.velocity.y = t.walkSpeed end,
  menuPrevious = function (t)
    t.menu.selected = t.menu.selected - 1
    if t.menu.selected == 0 then
      t.menu.selected = #t.menu.options
    end
  end,
  menuNext = function (t)
    t.menu.selected = t.menu.selected + 1
    if t.menu.selected == #t.menu.options + 1 then
      t.menu.selected = 1
    end
  end,
  menuSelect = function (t)
    (t.menu.callbacks[t.menu.selected] or function () end)()
  end,
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

local function doActionIfKeyIsDown(keys, input, components, isMenu)
  local held = {}

  for virtualKey, physicalKey in pairs(keys) do
    if M.love.keyboard.isDown(physicalKey) then
      held[#held+1] = virtualKey
      for actionName, inputKey in pairs(input) do
        if inputKey == virtualKey and not isMenu then
          actions[actionName](components)
        end
      end
    end
  end

  return held
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

function M.update(keys, inputs, velocities, impulseSpeeds, menus)
  for entity, input in pairs(inputs or {}) do
    local components = {
      velocity = (velocities or {})[entity],
      walkSpeed = ((impulseSpeeds or {})[entity] or {}).walk,
    }
    local isMenu = (menus or {})[entity]
    local held = doActionIfKeyIsDown(keys, input, components, isMenu)
    doOmissionIfKeyIsUp(held, input, components.velocity)
  end
end

function M.keypressed(key, keys, inputs, menus, inMenu)
  if inMenu then
    local pressedVirtualKey
    for virtualKey, physicalKey in pairs(keys) do
      if physicalKey == key then
        pressedVirtualKey = virtualKey
        break
      end
    end
    for entity, menu in pairs(menus or {}) do
      for actionName, virtualKey in pairs(inputs[entity]) do
        if pressedVirtualKey == virtualKey then
          actions[actionName]{menu=menu}
        end
      end
    end
  end
end

return M
