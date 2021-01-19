local M = {}

function  M.buildArguments(entity, components)
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

local function updateBox(b)
  local x = b.position.x - b.origin.x
  local y = b.position.y - b.origin.y
  b.left = x
  b.right = x + b.width
  b.top = y
  b.bottom = y + b.height
  b.horizontalCenter = x + b.width/2
  b.verticalCenter = y + b.height/2
end

function M.getTranslatedBox(position, box)
  local translatedBox = {
    position = position,  -- keep reference for translations
    origin = {x = box.origin.x, y = box.origin.y},
    width = box.width,
    height = box.height
  }
  updateBox(translatedBox)
  return translatedBox
end

function M.areOverlapped(tbox1, tbox2)
  return tbox1.left <= tbox2.right and tbox1.right >= tbox2.left
    and tbox1.top <= tbox2.bottom and tbox1.bottom >= tbox2.top
end

M.translate = {
  left = function (b, v)
    b.position.x = v + b.origin.x
    updateBox(b)
  end,
  bottom = function (b, v)
    b.position.y = v - b.height + b.origin.y
    updateBox(b)
  end,
  right = function (b, v)
    b.position.x = v - b.width + b.origin.x
    updateBox(b)
  end,
  top = function (b, v)
    b.position.y = v + b.origin.y
    updateBox(b)
  end,
  horizontalCenter = function (b, v)
    b.position.x = v - b.width/2 + b.origin.x
    updateBox(b)
  end,
  verticalCenter = function (b, v)
    b.position.y = v - b.height/2 + b.origin.y
    updateBox(b)
  end,
}

return M
