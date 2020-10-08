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

    for itemIndex, itemData in pairs(state.currentLevel.entitiesData[itemGroupName] or {}) do
      local id = itemGroupName .. tostring(itemIndex)
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


local function healthSupply(state)
  -- healing depends on living, player and position
  -- components.assertDependency(state, "healing", "living",
  --                                       "players", "positions")
  local collisionBoxes = state.collisionBoxes
  local positions = state.positions

  if collisionBoxes and positions then
    for entity, collector in pairs(state.collectors or {}) do
      local collisionBox = collisionBoxes[entity]
      local position = positions[entity]
      local collector = state.collectors[entity]

      if collisionBox and position and collector then
        local livingEntities = state.living or {}
        local livingEntity = livingEntities[entity] or {}
        -- components.assertExistence(entity, "player", {position, "position"},
        --                            {collisionBox, "collisionBox"},
        --                            {livingEntity, "living"})
        local box = collisionBox:translated(position)
        local parameter = livingEntity.health or 0
        -- components.assertExistence(entity, "player", {parameter, "health"})

        for itemEntity, itemBox in pairs(state.healing or {}) do
          local itemPosition = state.positions[itemEntity]

          if itemBox:translated(itemPosition):intersects(box) then
            livingEntity.health = parameter + itemBox.effectAmount
            state.positions[itemEntity] = nil
            state.healing[itemEntity] = nil
          end

        end
      end
    end
  end
end



local function experienceSupply(state)
  -- experienceEffect depends on player and position
  -- components.assertDependency(state, "experienceEffect", "players",
  --                             "positions")

  for entity, player in pairs(state.players) do
    local collector = state.collectors[entity]

    if collector then
      local position = state.positions[entity]
      local collisionBox = state.collisionBoxes[entity]
      -- components.assertExistence(entity, "player", {position, "position"},
      --                            {collisionBox, "collisionBox"})
      local box = collisionBox:translated(position)

      local parameter = player.experience

      for itemEntity, itemBox in pairs(state.experienceEffect or {})
          do
        local itemPosition = state.positions[itemEntity]

        if itemBox:translated(itemPosition):intersects(box) then
          player.experience = parameter + itemBox.effectAmount
          positions = nil
          state.experienceEffect[itemEntity] = nil
        end

      end
    end
  end
end


function M.update(state)
  healthSupply(state)
  -- experienceSupply(state)
end

return M
