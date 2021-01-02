local M = {}

local function setComponent(world, componentName, entity, value)
  world.gameState.components[componentName] =
    world.gameState.components[componentName] or {}
  world.gameState.components[componentName][entity] = value
end

local function setComponentAttribute(world, componentName, entity,
                                     attribute, value)
  world.gameState.components[componentName] =
    world.gameState.components[componentName] or {}
  world.gameState.components[componentName][entity] =
    world.gameState.components[componentName][entity] or {}
  world.gameState.components[componentName][entity][attribute] = value
end

local function createDefaultPosition(world, entity)
  local width, height = M.love.graphics.getDimensions()
  setComponentAttribute(world, "position", entity, "x", width/2)
  setComponentAttribute(world, "position", entity, "y", height/2)
end

local function createDefaultVelocity(world, entity)
  setComponentAttribute(world, "velocity", entity, "x", 0)
  setComponentAttribute(world, "velocity", entity, "y", 0)
end

local function createDefaults(world, entity)
  setComponentAttribute(world, "impulseSpeed", entity, "walk", 400)
  setComponentAttribute(world, "impulseSpeed", entity, "jump", 1500)
  createDefaultPosition(world, entity)
  createDefaultVelocity(world, entity)
end

local function copyMenuToState(world, menu, entity)
  local menuOptions = {}
  for _, option in ipairs(menu.options) do
    menuOptions[#menuOptions+1] = option
  end
  setComponentAttribute(world, "menu", entity, "options", menuOptions)
  setComponentAttribute(world, "menu", entity, "callbacks", {})
  setComponentAttribute(world, "menu", entity, "selected", 1)
  world.gameState.inMenu = true  -- cambiar por escena
end

local stateBuilders = {
  input = function (world, hasInput, entity)
    if hasInput then
      setComponent(world, "input", entity, {})
      for _, commandActions in pairs(world.hid.commands or {}) do
        for k, action in pairs(commandActions) do
          if k == M.entityTagger.getName(entity) then
            setComponentAttribute(world, "input", entity, action, false)
          end
        end
      end
      createDefaults(world, entity)
    end
  end,
  impulseSpeed = function (world, component, entity)
    for impulseName, speed in pairs(component) do
      setComponentAttribute(world, "impulseSpeed", entity, impulseName,
                            speed)
    end
  end,
  collector = function (world, isCollector, entity)
    setComponent(world, "collector", entity, isCollector)
  end,
  collectable = function (world, isCollectable, entity)
    if isCollectable then
      setComponent(world, "collectable", entity,
                    {name = M.entityTagger.getName(entity)})
    end
  end,
  collisionBox = function (world, component, entity)
    local t = {
      origin = {x = component[1], y = component[2]},
      width = component[3],
      height = component[4],
    }
    for k, v in pairs(t) do
      setComponentAttribute(world, "collisionBox", entity, k, v)
    end
    createDefaultPosition(world, entity)
  end,
  animations = function (world, component, entity)
    local entityName = M.entityTagger.getName(entity)
    local animations = world.resources.animations or {}
    animations[entityName] = animations[entityName] or {}
    local name
    for animationName, animation in pairs(component) do
      local t = {
        frames = {},
        durations = {},
        looping = false
      }
      for k, v in ipairs(animation) do
        if type(v) == "boolean" then
          t.looping = v
          break
        end
        local i = math.ceil(k/2)
        if k % 2 == 0 then
          t.durations[i] = v
        else
          t.frames[i] = v
        end
      end
      animations[entityName][animationName] = t
      name = name or animationName
    end
    setComponentAttribute(world, "animation", entity, "name", name)
    setComponentAttribute(world, "animation", entity, "frame", 1)
    setComponentAttribute(world, "animation", entity, "time", 0)
    setComponentAttribute(world, "animation", entity, "ended", false)

    world.resources.animations = animations
  end,
  solid = function (world, isSolid, entity)
    if isSolid then
      setComponent(world, "solid", entity, {})
      createDefaultPosition(world, entity)
      createDefaultVelocity(world, entity)
    end
  end,
  collideable = function (world, type, entity)
    local name = M.entityTagger.getName(entity)
    setComponentAttribute(world, "collideable", entity, "name", name)
    assert(type == "rectangle" or type == "triangle",
           "Unexpected collideable type \"" .. type .. "\" for entity \""
           .. name .. "\"")
  end,
  gravitational = function (world, isGravitational, entity)
    setComponent(world, "gravitational", entity, isGravitational)
    createDefaultPosition(world, entity)
    createDefaultVelocity(world, entity)
  end,
  climber = function (world, isClimber, entity)
    if isClimber then
      setComponent(world, "climber", entity, {})
      createDefaultPosition(world, entity)
      createDefaultVelocity(world, entity)
    end
  end,
  ladder = function (world, isLadder, entity)
    if isLadder then
      local name = M.entityTagger.getName(entity)
      setComponentAttribute(world, "ladder", entity, "name", name)
    end
  end,
}

local function buildFromVertex(entity, entityComponents, vertex, world)
  if entityComponents.collideable or entityComponents.ladder then
    local x1 = math.min(vertex[1], vertex[3])
    local x2 = math.max(vertex[1], vertex[3])
    local y1 = math.min(vertex[2], vertex[4] or vertex[2])
    local y2 = math.max(vertex[2], vertex[4] or vertex[2])
    setComponentAttribute(world, "position", entity, "x", (x1+x2)/2)
    setComponentAttribute(world, "position", entity, "y", (y1+y2)/2)
    local width = x2 - x1
    local height = y2 - y1
    setComponentAttribute(world, "collisionBox", entity, "origin",
                          {x = width/2, y = height/2})
    setComponentAttribute(world, "collisionBox", entity, "width",
                          width)
    setComponentAttribute(world, "collisionBox", entity, "height",
                          height)
    if not entityComponents.ladder
        and entityComponents.collideable == "triangle"
        and vertex[2] ~= vertex[4] then
      setComponentAttribute(world, "collideable", entity, "normalPointingUp",
                            vertex[2] > vertex[4])
      local rising = (vertex[1]-vertex[3]) * (vertex[2]-vertex[4]) < 0
      setComponentAttribute(world, "collideable", entity, "rising",
                            rising)
    end
  else
    setComponentAttribute(world, "position", entity, "x", vertex[1])
    setComponentAttribute(world, "position", entity, "y", vertex[2])
  end
end

local function buildNonMenu(entityName, entityComponents, world)
  local entity = nil
  if not entityComponents.menu then
    for componentName, component in pairs(entityComponents) do
      entity = entity or M.entityTagger.tag(entityName)
      if componentName == "input" and entityComponents.gravitational then
        createDefaults(world, entity)
      end
      assert(stateBuilders[componentName],
              "Entity \"" .. entityName .. "\" has a component named \""
              .. componentName .. "\" that was not expected in config.lua")
              stateBuilders[componentName](world, component, entity)
    end
  end
  return entity
end

local function buildMenu(config, world)
  local foundMenu = false
  for entityName, entityComponents in pairs(config.entities) do
    for componentName, component in pairs(entityComponents) do
      if componentName == "menu" and world.gameState.inMenu == nil then
        local entity = M.entityTagger.tag(entityName)
        foundMenu = true
        copyMenuToState(world, component, entity)
        world.gameState.components.input =
          world.gameState.components.input or {}
        world.gameState.components.input[entity] =
          entityComponents.input and {}
      end
    end
  end

  return not foundMenu
end

local function buildNonMenuIfInLevel(config, world, levelName, entityName,
                                     entityComponents)
  local firstLevelName = config.firstLevel or next(config.levels)
  levelName = levelName or firstLevelName
  local level = config.levels[levelName] or {}
  local vertices = level[entityName]
  if vertices then
    if type(vertices[1]) == "number" then
      vertices = {vertices}
    end
    for _, vertex in ipairs(vertices) do
      local entity = buildNonMenu(entityName, entityComponents, world)
      if entity then
        buildFromVertex(entity, entityComponents, vertex, world)
      end
    end
  end
end

local function buildActions(world)
  world.hid.actions = {
    walkLeft = function (c) c.velocity.x = -c.impulseSpeed.walk end,
    walkRight = function (c) c.velocity.x = c.impulseSpeed.walk end,
    walkUp = function (c) c.velocity.y = -c.impulseSpeed.walk end,
    walkDown = function (c) c.velocity.y = c.impulseSpeed.walk end,
    stopWalkingHorizontally = function (c) c.velocity.x = 0 end,
    stopWalkingVertically = function (c) 
      if not c.gravitational then
        c.velocity.y = 0
      end
    end,
    menuPrevious = function (c)
      c.menu.selected = c.menu.selected - 1
      if c.menu.selected == 0 then
        c.menu.selected = #c.menu.options
      end
    end,
    menuNext = function (c)
      c.menu.selected = c.menu.selected + 1
      if c.menu.selected == #c.menu.options + 1 then
        c.menu.selected = 1
      end
    end,
    menuSelect = function (c)
      (c.menu.callbacks[c.menu.selected] or function () end)()
    end,
  }
end

local function buildResources(config, world)
  world.resources = {}
  if config.spriteSheet and config.sprites then
    local spriteSheet = M.love.graphics.newImage(config.spriteSheet)
    world.resources = {
      spriteSheet = spriteSheet,
      spriteScale = config.spriteScale or 1,
      sprites = {}
    }
    for _, spriteData in ipairs(config.sprites) do
      local x, y, w, h, originX, originY = unpack(spriteData)
      local newSprite = {}
      newSprite.quad = M.love.graphics.newQuad(x, y, w, h,
                                               spriteSheet:getDimensions())
      newSprite.origin = {x = originX, y = originY}
      world.resources.sprites[#world.resources.sprites+1] = newSprite
    end
  end
end

local function entityCanBeBuilt(config, entityName, componentPairs)
  local canBeBuilt = true
  for _, t in ipairs(componentPairs) do
    canBeBuilt = canBeBuilt and not config.entities[entityName][t[1]]
  end
  
  return canBeBuilt
end

local function checkComponentsCompatibility(config, entityName, componentPairs)
  for _, t in ipairs(componentPairs) do
    local components = config.entities[entityName]
    local v1, v2 = unpack(t)
    assert(not components[v1] or not components[v2],
           "Entities must not be " .. v1 .. "s and " .. v2 .. "s at the same"
           .. "time, but entity \"" .. entityName .. "\" has both "
           .. "components declared in config.lua")
  end
end

function M.buildState(config, world, levelName)
  world.gameState = world.gameState or {}
  world.gameState.components = {garbage = {}}
  if config.entities then
    local hasNoMenuComponents = buildMenu(config, world)
    if hasNoMenuComponents then
      local componentPairs = {
        {"collectable", "collector"},
        {"collideable", "solid"},
        {"ladder", "climber"}
      }
      for entityName, entityComponents in pairs(config.entities) do
        checkComponentsCompatibility(config, entityName, componentPairs)
        if config.levels then
          buildNonMenuIfInLevel(config, world, levelName, entityName,
                                entityComponents)
        elseif entityCanBeBuilt(config, entityName, componentPairs) then
          buildNonMenu(entityName, entityComponents, world)
        end
      end
    end
  end
end

function M.load(love, entityTagger)
  M.love = love
  M.entityTagger = entityTagger
end

function M.buildWorld(config)
  local world = {hid = {}}

  world.physics = config.physics or {}
  world.physics.gravity = world.physics.gravity or 0

  world.hid.keys = config.keys or {}
  world.hid.keys.left = world.hid.keys.left or "a"
  world.hid.keys.right = world.hid.keys.right or "d"
  world.hid.keys.up = world.hid.keys.up or "w"
  world.hid.keys.down = world.hid.keys.down or "s"
  world.hid.keys.start = world.hid.keys.start or "return"

  buildActions(world)
  buildResources(config, world)
  M.buildState(config, world)

  return world
end

function M.setInputs(world, entityName, actionCommands)
  local commands = world.hid.commands or {}
  for action, command in pairs(actionCommands) do
    local mustBeSet = true
    for _, commandKey in ipairs(command.keys or {}) do
      if not world.hid.keys[commandKey] then
        mustBeSet = false  -- throw error
      end
    end
    if mustBeSet then
      commands[command] = commands[command] or {}
      commands[command][entityName] = action
      local entities = M.entityTagger.getIds(entityName)
      for _, entity in ipairs(entities or {}) do
        setComponentAttribute(world, "input", entity, action, false)
      end
    end
  end
  world.hid.commands = commands
end

return M
