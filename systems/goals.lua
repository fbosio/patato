local components = require "components"
local box = require "components.box"
local items = require "systems.items"
local levels = require "levels"
local M = {}


function M.load(state, currentLevel)
  -- components.assertDependency(state, "goals", "positions")

  for goalIndex, goalData in pairs(currentLevel.entitiesData.goals or {}) do
    local id = "goal" .. tostring(goalIndex)
    state.positions[id] = {x = goalData[1], y = goalData[2]}
    state.goals[id] = box.GoalBox:new{
      width = 110,
      height = 110,
      nextLevel = goalData[3]
    }
  end
end


local function loadNextLevel(levels, goalBox, position, velocity, items,
                      state)
  local nextLevel = levels.level[goalBox.nextLevel]

  -- Player position loading and movement restore
  position.x = nextLevel.entitiesData.player[1][1]
  position.y = nextLevel.entitiesData.player[1][2]
  velocity.x = 0
  velocity.y = 0

  -- Reload goals and items
  items.reload(state, nextLevel)

  for _id in pairs(state.goals) do
    state.positions[_id] = nil
    state.goals[_id] = nil
  end

  if nextLevel.entitiesData.goals then
    M.load(state, nextLevel)
  end

  return nextLevel
end


function M.update(state, currentLevel)
  local nextLevel = currentLevel

  local positions = state.positions
  local velocities = state.velocities
  if positions and velocities then
    for entity, player in pairs(state.players or {}) do
      local collector = state.collectors[entity]

      if collector then
        local position = state.positions[entity]
        local velocity = state.velocities[entity]
        local collisionBox = state.collisionBoxes[entity]
        -- components.assertExistence(entity, "player", {position, "position"},
        --                             {collisionBox, "collisionBox"}, {velocity, "velocity"})

        local box = collisionBox:translated(position)

        for goalEntity, goalBox in pairs(state.goals or {}) do
          local goalPosition = state.positions[goalEntity]

          if goalBox:translated(goalPosition):intersects(box) then
            nextLevel = loadNextLevel(levels, goalBox, position, velocity,
                                      items, state)
            break
          end
        end -- for goalEntity
      end
    end -- for entity, player
  end

  return nextLevel
end


return M
