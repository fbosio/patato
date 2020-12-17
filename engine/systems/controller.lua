local M = {}

local actions = {
  walkLeft = function (t) t.velocity.x = -t.walkSpeed end,
  walkRight = function (t) t.velocity.x = t.walkSpeed end,
  walkUp = function (t) t.velocity.y = -t.walkSpeed end,
  walkDown = function (t) t.velocity.y = t.walkSpeed end,
  -- menuPrevious = function (t)
  --   local menu = t.menu
  --   menu.selected = menu.selected - 1
  --   if menu.selected == 0 then
  --     menu.selected = #menu.options
  --   end
  -- end,
  -- menuNext = function (t)
  --   local menu = t.menu
  --   menu.selected = menu.selected + 1
  --   if menu.selected == #menu.options + 1 then
  --     menu.selected = 1
  --   end
  -- end,
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

local function doActionIfKeyIsDown(keys, input, components)
  local held = {}

  for virtualKey, physicalKey in pairs(keys) do
    if M.love.keyboard.isDown(physicalKey) then
      held[#held+1] = virtualKey
      for actionName, inputKey in pairs(input) do
        if inputKey == virtualKey then
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
  inputs = inputs or {}

  for entity, input in pairs(inputs) do
    local components = {
      velocity = (velocities or {})[entity],
      walkSpeed = ((impulseSpeeds or {})[entity] or {}).walk,
      -- menu = (menus or {})[entity]
    }
    local held = doActionIfKeyIsDown(keys, input, components)
    doOmissionIfKeyIsUp(held, input, components.velocity)
  end
end

function M.keypressed(key, menus)
  for _, menu in pairs(menus) do
    (({
      w = function (t)
        local menu = t.menu
        menu.selected = menu.selected - 1
        if menu.selected == 0 then
          menu.selected = #menu.options
        end
      end,
      s = function (t)
        local menu = t.menu
        menu.selected = menu.selected + 1
        if menu.selected == #menu.options + 1 then
          menu.selected = 1
        end
      end,
    })[key] or function () end){menu = menu}
  end
end

return M
