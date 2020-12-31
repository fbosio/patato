local M = {}

local heldKeys = {}

local function setInputActions(inputs, commandActions, value)
  for entity, action in pairs(commandActions) do
    inputs[entity][action] = value
  end
end

local function updateInputsUsingNormalCommands(inputs, commands, virtualKey)
  for command, commandActions in pairs(commands) do
    if command.key == virtualKey and not command.oneShot
        and not command.release then
      for entity, action in pairs(commandActions) do
        inputs[entity][action] = true
        local wasNotDown = true
        for _, heldKey in ipairs(heldKeys) do
          if heldKey == virtualKey then
            wasNotDown = false
            break
          end
        end
        if wasNotDown then
          heldKeys[#heldKeys+1] = virtualKey
        end
      end
    end
  end
end

local function updateInputsUsingReleaseCommands(inputs, commands, virtualKey)
  local isKeyUp = false
  for i, heldKey in ipairs(heldKeys) do
    if heldKey == virtualKey then
      isKeyUp = true
      table.remove(heldKeys, i)
      break
    end
  end

  if isKeyUp then
    for command, commandActions in pairs(commands) do
      if command.key == virtualKey then
        if command.release then
          setInputActions(inputs, commandActions, true)
        elseif not command.oneShot then
          setInputActions(inputs, commandActions, false)
        end
      end
    end
  end
end

function M.load(love)
  M.love = love
end

function M.update(hid, components)
  for virtualKey, physicalKey in pairs(hid.keys) do
    if M.love.keyboard.isDown(physicalKey) then
      updateInputsUsingNormalCommands(components.input or {},
                                      hid.commands or {}, virtualKey)
    else
      updateInputsUsingReleaseCommands(components.input or {},
                                       hid.commands or {}, virtualKey)
    end
  end

  for entity, input in pairs(components.input or {}) do
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
    if components.animation then
      entityComponents.animation = entityComponents.animation or {}
    end
    for actionName, enabled in pairs(input) do
      if enabled then
        hid.actions[actionName](entityComponents)
      end
    end
  end
end

function M.keypressed(key, hid, inputs, menus, inMenu)
  for virtualKey, physicalKey in pairs(hid.keys) do
    if physicalKey == key then
      for command, commandActions in pairs(hid.commands or {}) do
        if command.oneShot then
          setInputActions(inputs, commandActions, command.key == virtualKey)
        end
      end
    end
  end
  if menus then
    for entity, input in pairs(inputs) do
      for actionName, enabled in pairs(input) do
        if enabled then
          hid.actions[actionName]{menu = menus[entity]}
        end
      end
    end
  end
end

return M
