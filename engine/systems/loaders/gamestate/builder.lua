local component = require "engine.systems.loaders.gamestate.component"

local M = {}

function M.load(love, entityTagger, menuName, components)
  component.load(love, components)
  M.entityTagger = entityTagger
  M.menuName = menuName
end

function M.buildFromVertices(vertices, entity, entityData)
  component.setAttribute("position", entity, "x", vertices[1])
  component.setAttribute("position", entity, "y", vertices[2])
  if #vertices > 2 then
    local x1 = math.min(vertices[1], vertices[3])
    local y1 = math.min(vertices[2], vertices[4] or vertices[2])
    local x2 = math.max(vertices[1], vertices[3])
    local y2 = math.max(vertices[2], vertices[4] or vertices[2])
    component.setAttribute("position", entity, "x", x1)
    component.setAttribute("position", entity, "y", y1)
    component.setAttribute("collisionBox", entity, "origin",
                            {x = 0, y = 0})
    component.setAttribute("collisionBox", entity, "width", x2 - x1)
    component.setAttribute("collisionBox", entity, "height", y2 - y1)
    if entityData.collideable == "triangle"
        and vertices[2] ~= vertices [4] then
      component.setAttribute("collideable", entity, "normalPointingUp",
                            vertices[2] > vertices[4])
      local rising = (vertices[1]-vertices[3])
                      * (vertices[2]-vertices[4]) < 0
      component.setAttribute("collideable", entity, "rising",
                            rising)
    end
  end
end

local flagStateBuilders = {
  controllable = function (entity)
    component.set("controllable", entity, {})
    if not M.menuName then
      component.setDefaults(entity)
    end
  end,
  collectable = function (entity)
    local name = M.entityTagger.getName(entity)
    component.setAttribute("collectable", entity, "name", name)
  end,
  trellis = function (entity)
    component.set("trellis", entity, true)
  end,
  limiter = function (entity)
    component.set("limiter", entity, true)
  end,
  camera = function (entity)
    component.set("camera", entity, true)
    component.setAttribute("position", entity, "x", 0)
    component.setAttribute("position", entity, "y", 0)
    component.matchCollisionBoxToScreen(entity)
  end,
  window = function (entity)
    component.set("window", entity, true)
    component.setAttribute("position", entity, "x", 0)
    component.setAttribute("position", entity, "y", 0)
  end
}
for _, k in ipairs{"collector", "solid", "gravitational", "climber"} do
  flagStateBuilders[k] = function (entity)
    component.setAttribute(k, entity, "enabled", true)
    component.setDefaultPosition(entity)
    component.setDefaultVelocity(entity)
  end
end

function M.flags(flags, entity)
  for _, flag in ipairs(flags) do
    assert(flagStateBuilders[flag], 'Unexpected flag "' .. flag .. '" for '
           .. "entity " .. M.entityTagger.getName(entity)
           .. " in config.lua")(entity)
  end
end

function M.resources(resources, entity)
  if not resources.animations then return end
  local name = next(resources.animations)
  component.setAttribute("animation", entity, "name", name)
  component.setAttribute("animation", entity, "frame", 1)
  component.setAttribute("animation", entity, "time", 0)
  component.setAttribute("animation", entity, "ended", false)
  component.setAttribute("animation", entity, "flipX", false)
end

function M.impulseSpeed(speeds, entity)
  for attribute, speed in pairs(speeds) do
    component.setAttribute("impulseSpeed", entity, attribute, speed)
  end
end

function M.menu(data, entity)
  component.setAttribute("menu", entity, "callbacks", {})
  component.setAttribute("menu", entity, "selected", 1)
  for attribute, value in pairs(data) do
    component.setAttribute("menu", entity, attribute, value)
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

function M.collideable(kind, entity)
  local name = M.entityTagger.getName(entity)
  assert(kind == "rectangle" or kind == "triangle",
         "Unexpected collideable type \"" .. kind .. "\" for entity \""
         .. name .. "\"")
  component.setAttribute("collideable", entity, "name", name)
end

return M
