local M = {}

local function setInputActions(inputs, commandActions, value)
  for entityName, action in pairs(commandActions) do
    local entities = M.entityTagger.getIds(entityName)
    for _, entity in ipairs(entities or {}) do
      (inputs[entity] or {})[action] = value
    end
  end
end

local function buildActionArguments(entity, components)
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
  return entityComponents
end

function M.load(love, entityTagger)
  M.love = love
  M.entityTagger = entityTagger
end

function M.update(hid, components)
  for command, commandActions in pairs(hid.commands or {}) do
    if not command.oneShot and not command.release then
      local mustExecute = false
      for _, commandKey in ipairs(command.keys or {}) do
        local physicalKey = hid.keys[commandKey]
        local joystickHat = (hid.joystick.hats or {})[commandKey]
        local directions = hid.joystick.current
                           and hid.joystick.current:getHat(1) or ""
        local isHatInDirection = joystickHat == string.sub(directions, 1, 1)
                                 or joystickHat == string.sub(directions, 2, 2)
        if M.love.keyboard.isDown(physicalKey) or isHatInDirection then
          mustExecute = true
          break
        end
      end
      setInputActions(components.input or {}, commandActions, mustExecute)
    end
  end

  for entity, input in pairs(components.input or {}) do
    local entityComponents = buildActionArguments(entity, components)
    for actionName, enabled in pairs(input) do
      if enabled then
        hid.actions[actionName](entityComponents)
      end
    end
  end
end

local function executeAction(hid, commandActions, components)
  for entityName, action in pairs(commandActions) do
    local entities = M.entityTagger.getIds(entityName)
    for _, entity in ipairs(entities or {}) do
      if components.input[entity] then
        local entityComponents = buildActionArguments(entity, components)
        hid.actions[action](entityComponents)
      end
    end
  end
end

local function checkAndExecuteAction(key, commandKeys, hid, commandActions,
                                     components)
  local mustExecute = false
  for _, commandKey in ipairs(commandKeys or {}) do
    local physicalKey = hid.keys[commandKey]
    if physicalKey == key then
      mustExecute = true
      break
    end
  end
  if mustExecute then
    executeAction(hid, commandActions, components)
  end
end

function M.keypressed(key, hid, components)
  for command, commandActions in pairs(hid.commands or {}) do
    if command.oneShot then
      checkAndExecuteAction(key, command.keys, hid, commandActions, components)
    end
  end
end

function M.keyreleased(key, hid, components)
  for command, commandActions in pairs(hid.commands or {}) do
    if command.release then
      checkAndExecuteAction(key, command.keys, hid, commandActions, components)
    end
  end
end

function M.joystickadded(joystick, hid)
  hid.joystick.current = hid.joystick.current or joystick
end

function M.joystickremoved(joystick, hid)
  hid.joystick.current = hid.joystick.current == joystick and nil
                         or hid.joystick.current
end

function M.joystickhat(joystick, hat, direction, hid, components)
  if joystick == hid.joystick.current and hat == 1 then
    for command, commandActions in pairs(hid.commands or {}) do
      if command.release and direction == "c" then
        executeAction(hid, commandActions, components)
      elseif command.oneShot and direction ~= "c" then
        local mustExecute = false
        for _, commandKey in ipairs(command.keys or {}) do
          local joystickHat = (hid.joystick.hats or {})[commandKey]
          if joystickHat == direction then
            mustExecute = true
            break
          end
        end
        if mustExecute then
          executeAction(hid, commandActions, components)
        end
      end
    end
  end
end

function M.joystickpressed(joystick, button, hid, components)
  if joystick == hid.joystick.current then
    for command, commandActions in pairs(hid.commands or {}) do
      if command.oneShot then
        local mustExecute = false
        for _, commandKey in ipairs(command.keys or {}) do
          local joystickButton = (hid.joystick.buttons or {})[commandKey]
          if joystickButton == button then
            mustExecute = true
            break
          end
        end
        if mustExecute then
          executeAction(hid, commandActions, components)
        end
      end
    end
  end
end

return M
