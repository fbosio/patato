local M = {}

local function buildArguments(entity, components)
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
  return setmetatable(entityComponents, {
    __index = function (_, attr)
      error("Unexpected component \"" .. attr .. "\".", 2)
    end
  })
end

function M.load(love, entityTagger)
  M.love = love
  M.entityTagger = entityTagger
end

function M.update(hid, components)
  for entityName, entityCommands in pairs(hid.commands.hold or {}) do
    for input, callback in pairs(entityCommands) do
      local physicalKey = hid.keys[input]
      local physicalHat = hid.joystick.hats[input]
      local physicalButton = hid.joystick.buttons[input]
      local isHatDown, isButtonDown
      if hid.joystick.current then
        local current = hid.joystick.current
        isHatDown = physicalHat == current:getHat()
        isButtonDown = current:isDown(physicalButton)
      end
      if M.love.keyboard.isDown(physicalKey) or isHatDown or isButtonDown then
        local entities = M.entityTagger.getIds(entityName)
        for _, entity in ipairs(entities) do
          local controllables = components.controllable or {}
          local controllableEntity = (controllables[entity] or {}).hold or {}
          controllableEntity[input] = true
          local entityComponents = buildArguments(entity, components)
          callback(entityComponents)
        end
      end
    end
  end
end

local function checkEvent(input, kind, hidInputs, commands, components)
  for entityName, entityCommands in pairs(commands[kind] or {}) do
    for commandInput, callback in pairs(entityCommands) do
      local physicalInput = hidInputs[commandInput]
      local entities = M.entityTagger.getIds(entityName)
      if physicalInput == input then
        for _, entity in ipairs(entities) do
          local entityComponents = buildArguments(entity, components)
          callback(entityComponents)
        end
      end
    end
  end
end

function M.keypressed(key, hid, components)
  checkEvent(key, "press", hid.keys, hid.commands, components)
end

function M.keyreleased(key, hid, components)
  checkEvent(key, "release", hid.keys, hid.commands, components)
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
    if direction == "c" then
      for entityName, entityCommands in pairs(hid.commands.release or {}) do
        for input, callback in pairs(entityCommands) do
          local entities = M.entityTagger.getIds(entityName)
          for _, entity in ipairs(entities) do
            local controllables = components.controllable or {}
            local controllableEntity = (controllables[entity] or {}).hold or {}
            if controllableEntity[input] then
              controllableEntity[input] = false
              local entityComponents = buildArguments(entity, components)
              callback(entityComponents)
            end
          end
        end
      end
    else
      checkEvent(nil, "press", {}, hid.commands, components)
    end
  end
end

function M.joystickpressed(joystick, button, hid, components)
  if joystick == hid.joystick.current then
    checkEvent(button, "press", hid.joystick.buttons, hid.commands,
               components)
  end
end

function M.joystickreleased(joystick, button, hid, components)
  if joystick == hid.joystick.current then
    checkEvent(button, "release", hid.joystick.buttons, hid.commands,
               components)
  end
end

return M
