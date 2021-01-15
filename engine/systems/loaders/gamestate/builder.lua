local component = require "engine.systems.loaders.gamestate.component"
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
  collector = function (entity)
    M.component.set("collector", entity, true)
  end,
  collectable = function (entity)
    local name = M.entityTagger.getName(entity)
    M.component.setAttribute("collectable", entity, "name", name)
  end,
}

function M.flags(flags, entity, hid)
  for _, flag in ipairs(flags) do
    flagStateBuilders[flag](entity, hid)
  end
end

function M.resources(resources, entity)
  if not resources.animations then return end
  local name = next(resources.animations)
  component.setAttribute("animation", entity, "name", name)
  component.setAttribute("animation", entity, "frame", 1)
  component.setAttribute("animation", entity, "time", 0)
  component.setAttribute("animation", entity, "ended", false)
end

function M.impulseSpeed(speeds, entity)
  for attribute, speed in pairs(speeds) do
    M.component.setAttribute("impulseSpeed", entity, attribute, speed)
  end
end

function M.menu(data, entity)
  for attribute, value in pairs(data) do
    M.component.setAttribute("menu", entity, attribute, value)
  end
end

function M.collisionBox(box, entity)
  local t = {
    origin = {x = box[1], y = box[2]},
    width = box[3],
    height = box[4],
  }
  for k, v in pairs(t) do
    component.setAttribute("collisionBox", entity, k, v)
  end
  component.setDefaultPosition(entity)
end

function M.load(entityTagger, inMenu, component)
  M.entityTagger = entityTagger
  M.inMenu = inMenu
  M.component = component
end

return M
