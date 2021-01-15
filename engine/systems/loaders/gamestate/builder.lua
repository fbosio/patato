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
    component.setDefaults(M.love, entity)
  end,
}

function M.flags(flags, entity, hid)
  for _, flag in ipairs(flags) do
    flagStateBuilders[flag](entity, hid)
  end
end

function M.load(love, entityTagger, components)
  M.love = love
  M.entityTagger = entityTagger
  component.load(components)
end

return M
