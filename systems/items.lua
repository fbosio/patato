local components = require "components"
local box = require "components.box"
local M = {}


-- Link names in levels.lua to components in state
-- In other words, link each item name to its effect.
local componentGroup = {
  ["medkits"] = "healing",
  ["pomodori"] = "experienceEffect",
  -- ["my item"] = {"healing", "experienceEffect"}  -- several effects
}


function M.load(state)
  for itemGroupName, entity in pairs(componentGroup) do
    state[componentGroup[itemGroupName]] = {}
    local group = state[entity]
    local itemsData = state.currentLevel.entitiesData[itemGroupName] or {}

    for itemIndex, itemData in pairs(itemsData) do
      local id = itemGroupName .. tostring(itemIndex)
      state.positions = state.positions or {}
      state.positions[id] = {x = itemData[1], y = itemData[2]}
      -- if type(componentGroup[itemGroupName]) == "table"  -- several effects
      group[id] = box.ItemBox:new{effectAmount = 1}  -- hard-coded
    end
  end
end


function M.reload(state, nextLevel)
  -- Reload absolutely all components in the next level
  local names = {}

  -- Look for components in the componentGroup table
  for name in pairs(componentGroup) do
    names[#names + 1] = name
  end

  M.load(state, nextLevel, unpack(names))
end


local function supply(state, itemName, livingField)
  local collisionBoxes = state.collisionBoxes
  local positions = state.positions

  if collisionBoxes and positions then
    for entity, collector in pairs(state.collectors or {}) do
      local collisionBox = collisionBoxes[entity]
      local position = positions[entity]

      if collisionBox and position and collector then
        local livingComponents = state.living or {}
        local livingComponent = livingComponents[entity] or {}
        local box = collisionBox:translated(position)

        for itemEntity, itemBox in pairs(state[itemName] or {}) do
          local itemPosition = state.positions[itemEntity]
          if itemBox:translated(itemPosition):intersects(box) then
            if livingComponent[livingField] then
              livingComponent[livingField] = livingComponent[livingField]
                                             + itemBox.effectAmount
            end
            state.positions[itemEntity] = nil
            state[itemName][itemEntity] = nil
          end
        end
      end
    end
  end
end


local function healthSupply(state)
  supply(state, "healing", "health")
end


local function experienceSupply(state)
  supply(state, "experienceEffect", "experience")
end


function M.update(state)
  healthSupply(state)
  experienceSupply(state)
end


return M
