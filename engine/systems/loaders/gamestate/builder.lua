local component = require "engine.systems.loaders.gamestate.component"

local M = {}

local flagStateBuilders = {
  controllable = function (entity, hid)
    component.set("controllable", entity, {})
    for _, commandActions in pairs(hid.commands or {}) do
      for k, action in pairs(commandActions) do
        if k == M.entityTagger.getName(entity) then
          component.setAttribute("controllable", entity, action, false)
        end
      end
    end
    if not M.inMenu then component.setDefaults(M.love, entity) end
  end,
}

function M.flags(flags, entity, hid)
  for _, flag in ipairs(flags) do
    flagStateBuilders[flag](entity, hid)
  end
end

function M.impulseSpeed(speeds, entity, _)
  for attribute, speed in pairs(speeds) do
    component.setAttribute("impulseSpeed", entity, attribute, speed)
  end
end

function M.menu(data, entity, _)
  for attribute, value in pairs(data) do
    component.setAttribute("menu", entity, attribute, value)
  end
end

function M.load(love, entityTagger, inMenu, components)
  M.love = love
  M.entityTagger = entityTagger
  M.inMenu = inMenu
  component.load(components)
end

return M
