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

local function copyInputToState(world, input, entity, foundMenu,
                                isGravitational)
  if not next(input) then  -- check that input (non-boolean) is an empty table
    local defaultInput = foundMenu and {
      menuPrevious = "up",
      menuNext = "down",
      menuSelect = "start"
    } or isGravitational and {
      walkLeft = "left",
      walkRight = "right",
    } or {
      walkLeft = "left",
      walkRight = "right",
      walkUp = "up",
      walkDown = "down"
    }
    for actionName, defaultKey in pairs(defaultInput) do
      input[actionName] = input[actionName] or defaultKey
    end
  end
  for actionName, virtualKey in pairs(input) do
    if world.hid.keys[virtualKey] then
      setComponentAttribute(world, "input", entity, actionName,
                            virtualKey)
    end
  end
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
  input = function (world, component, entity)
    copyInputToState(world, component, entity)
    createDefaults(world, entity)
  end,
  impulseSpeed = function (world, component, entity)
    for impulseName, speed in pairs(component) do
      setComponentAttribute(world, "impulseSpeed", entity, impulseName,
                            speed)
    end
  end,
  collector = function (world, component, entity)
    setComponent(world, "collector", entity, component)
  end,
  collectable = function (world, _, entity)
    setComponent(world, "collectable", entity,
                 {name = M.entityTagger.getName(entity)})
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
  solid = function (world, component, entity)
    setComponent(world, "solid", entity, component)
    createDefaultPosition(world, entity)
    createDefaultVelocity(world, entity)
  end,
  collideable = function (world, _, entity)
    setComponent(world, "collideable", entity,
                 {name = M.entityTagger.getName(entity)})
  end,
  gravitational = function (world, component, entity)
    setComponent(world, "gravitational", entity, component)
    createDefaultPosition(world, entity)
    createDefaultVelocity(world, entity)
  end,
}

local function buildFromVertex(entity, entityComponents, vertex, world)
  if entityComponents.collideable then
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
        copyInputToState(world, component, entity, false, true)
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
        world.gameState.components.input[entity] = entityComponents.input
        copyInputToState(world, world.gameState.components.input[entity] or {},
                         entity, true)
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

local function buildActionsAndOmissions(world)
  world.hid.actions = {
    walkLeft = function (c) c.velocity.x = -c.impulseSpeed.walk end,
    walkRight = function (c) c.velocity.x = c.impulseSpeed.walk end,
    walkUp = function (c) c.velocity.y = -c.impulseSpeed.walk end,
    walkDown = function (c) c.velocity.y = c.impulseSpeed.walk end,
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
  setmetatable(world.hid.actions, {
    __index = function ()
      return function () end
    end
  })
  local function defaultHorizontalOmission(c)
    c.velocity.x = 0
  end
  local function defaultVerticalOmission(c)
    if not c.gravitational then
      c.velocity.y = 0
    end
  end
  world.hid.omissions = {
    [{"walkLeft", "walkRight"}] = defaultHorizontalOmission,
    [{"walkUp", "walkDown"}] = defaultVerticalOmission,
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

local function checkComponentsCompatibility(config, entityName)
  local isNotCollectable = not config.entities[entityName].collectable
  local isNotCollector = not config.entities[entityName].collector
  assert(isNotCollectable or isNotCollector,
          "Entities must not be collectables and collectors at the "
          .. "same time, but entity \"" .. entityName .. "\" has both "
          .. "components declared in config.lua")
  local isNotCollideable = not config.entities[entityName].collideable
  local isNotSolid = not config.entities[entityName].solid
  assert(isNotCollideable or isNotSolid,
          "Entities must not be collideables and solids at the "
          .. "same time, but entity \"" .. entityName .. "\" has both "
          .. "components declared in config.lua")

  return isNotCollectable and isNotCollideable
end

function M.buildState(config, world, levelName)
  world.gameState = world.gameState or {}
  world.gameState.components = {garbage = {}}
  if config.entities then
    local hasNoMenuComponents = buildMenu(config, world)
    if hasNoMenuComponents then
      for entityName, entityComponents in pairs(config.entities) do
        if config.levels then
          buildNonMenuIfInLevel(config, world, levelName, entityName,
                                entityComponents)
        else
          local canBeBuilt = checkComponentsCompatibility(config, entityName)
          if canBeBuilt then
            buildNonMenu(entityName, entityComponents, world)
          end
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

  buildActionsAndOmissions(world)
  buildResources(config, world)
  M.buildState(config, world)

  return world
end

return M
