local M = {}

local function setInputActions(inputs, commandActions, value)
  for entityName, action in pairs(commandActions) do
    local entities = M.entityTagger.getIds(entityName)
    for _, entity in ipairs(entities or {}) do
      (inputs[entity] or {})[action] = value
    end
  end
end

function M.load(love, entityTagger)
  M.love = love
  M.entityTagger = entityTagger
end

function M.update(hid, components)
  for command, commandActions in pairs(hid.commands or {}) do
    if not command.oneShot then
      local mustExecute = true
      for _, commandKey in ipairs(command.keys or {}) do
        local physicalKey = hid.keys[commandKey]
        local isKeyDown = M.love.keyboard.isDown(physicalKey)
        if not physicalKey or command.release and isKeyDown
            or not command.release and not isKeyDown then
          mustExecute = false
        end
      end
      setInputActions(components.input or {}, commandActions, mustExecute)
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
  for command, commandActions in pairs(hid.commands or {}) do
    if command.oneShot then
      local mustExecute = false
      for _, commandKey in ipairs(command.keys or {}) do
        local physicalKey = hid.keys[commandKey]
        if physicalKey == key then
          mustExecute = true
          break
        end
      end
      if mustExecute then
        for entityName, action in pairs(commandActions) do
          local entities = M.entityTagger.getIds(entityName)
          for _, entity in ipairs(entities or {}) do
            if inputs[entity] then
              hid.actions[action]{menu = menus[entity]}
            end
          end
        end
      end
    end
  end
end

return M
