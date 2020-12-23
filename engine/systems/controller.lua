local M = {}

local function doActionIfKeyIsDown(keys, actions, input, components, isMenu)
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

-- hid.omissions, held, input, entityComponents
local function doOmissionIfKeyIsUp(omissions, held, input, components)
  for omittedActions, omission in pairs(omissions) do
    local mustOmit = true

    for inputAction, inputKey in pairs(input) do
      for _, pressedKey in ipairs(held) do
        for _, omittedAction in ipairs(omittedActions) do
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
            omission(components)
          end
        end
      end
    end
  end
end

function M.load(love)
  M.love = love
end

function M.update(hid, components)
  for entity, input in pairs(components.input or {}) do
    local isMenu = (components.menu or {})[entity]
    local entityComponents = {}
    for componentName, component in pairs(components) do
      for k, v in pairs(component) do
        if k == entity then
          if componentName == "animation" then
            local proxy = {}
            setmetatable(proxy, {
              __newindex = function (_, attr, newName)
                if attr == "name" and v.name ~= newName then
                  v.name = newName
                  v.frame = 1
                  v.time = 0
                end
              end
            })
            entityComponents[componentName] = proxy
          else
            entityComponents[componentName] = v
          end
        end
      end
    end
    local held = doActionIfKeyIsDown(hid.keys, hid.actions, input,
                                     entityComponents, isMenu)
    doOmissionIfKeyIsUp(hid.omissions, held, input, entityComponents)
  end
end

function M.keypressed(key, hid, inputs, menus, inMenu)
  if inMenu then
    local pressedVirtualKey
    for virtualKey, physicalKey in pairs(hid.keys) do
      if physicalKey == key then
        pressedVirtualKey = virtualKey
        break
      end
    end
    for entity, menu in pairs(menus or {}) do
      for actionName, virtualKey in pairs(inputs[entity]) do
        if pressedVirtualKey == virtualKey then
          hid.actions[actionName]{menu = menu}
        end
      end
    end
  end
end

return M
