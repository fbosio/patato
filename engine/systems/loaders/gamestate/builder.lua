local M = {}

local flagStateBuilders = {
  controllable = function (entity, hid)
    M.component.set("controllable", entity, {})
    for _, commandActions in pairs(hid.commands or {}) do
      for k, action in pairs(commandActions) do
        if k == M.entityTagger.getName(entity) then
          M.component.setAttribute("controllable", entity, action, false)
        end
      end
    end
    if not M.inMenu then M.component.setDefaults(entity) end
  end,
  collector = function (entity, _)
    M.component.set("collector", entity, true)
  end,
  collectable = function (entity, _)
    local name = M.entityTagger.getName(entity)
    M.component.setAttribute("collectable", entity, "name", name)
  end,
}

function M.flags(flags, entity, hid)
  for _, flag in ipairs(flags) do
    flagStateBuilders[flag](entity, hid)
  end
end

function M.impulseSpeed(speeds, entity, _)
  for attribute, speed in pairs(speeds) do
    M.component.setAttribute("impulseSpeed", entity, attribute, speed)
  end
end

function M.menu(data, entity, _)
  for attribute, value in pairs(data) do
    M.component.setAttribute("menu", entity, attribute, value)
  end
end

function M.load(entityTagger, inMenu, component)
  M.entityTagger = entityTagger
  M.inMenu = inMenu
  M.component = component
end

return M
