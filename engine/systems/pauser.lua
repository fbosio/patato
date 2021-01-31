local M = {}

local componentsDisable = {
  "animation",
  "gravitational",
  "velocity",
  "camera",
  "controllable",
  "collector",
  "climber",
  "solid"
}
local previousState = {}

function M.pause(components)
  for _, componentDisable in ipairs(componentsDisable) do
    for entity, component in pairs(components[componentDisable] or {}) do
      previousState[componentDisable] = previousState[componentDisable] or {}
      previousState[componentDisable][entity] = component.enabled
      component.enabled = false
    end
  end
end

function M.unpause(components)
  for componentEnable, enabled in pairs(previousState) do
    print(componentEnable)
    for entity, component in pairs(components[componentEnable] or {}) do
      component.enabled = enabled[entity]
    end
  end
end

return M
