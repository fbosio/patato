local levels = require "levels"
local components = require "components"
local box = require "components.box"
local systems = require "systems"
local camera = require "systems.camera"
local items = require "systems.items"
local players = require "systems.players"
local terrain = require "systems.terrain"
local outline = require "outline"
local spawner = require "outline.spawner"


local spriteSheet


function love.load()
  local currentLevel = levels.level[levels.first]
  local playerName = "patato"
  spriteSheet = love.graphics.newImage("resources/sprites/patato.png")
  components.state = {
    collisionBoxes = {
      [playerName] = box.CollisionBox:new{width=50, height=100, maxFallSpeed=2500}
    },
    weights = {
      [playerName] = true
    },
    solids = {
      [playerName] = true
    },
    players = {
      [playerName] = {control=true},
    },
    speedImpulses = {
      [playerName] = {walk=400, crouchWalk=200, jump=1200, climb=400},
    },
    collectors = {
      [playerName] = true
    }
  }

  -- Move to init.load
  components.state.currentLevel = currentLevel

  terrain.load(components.state)
  players.load(playerName, components.state, spriteSheet)
  items.load(components.state)
  camera.load("my camera", playerName, components.state)
end


function love.update(dt)
  systems.update(components.state, dt)
  spawner.update(components.state)
end


function love.draw()
  outline.draw(components.state, camera.positions(components.state))
  systems.draw(components.state, spriteSheet, camera.positions(components.state))

  outline.debug(
    "mouse screen",
    function ()
      return love.mouse.getX() .. ", " .. love.mouse.getY()
    end,
    nil,
    1, 1, 1
  )
  outline.debug(
    "mouse level",
    function (position)
      local x = love.mouse.getX() + position.x
      local y = love.mouse.getY() - position.y
      return string.format("%.2f, %.2f", x, y)
    end,
    components.state.positions["my camera"],
    1, 1, 1
  )
  outline.debug(
    "player",
    function (position)
      return string.format("%.2f, %.2f", position.x, position.y)
    end,
    components.state.positions.patato,
    1, 1, 0
  )
  outline.debug(
    "health",
    function (health)
      return tostring(health)
    end,
    (components.state.living.patato or {}).health,
    1, 0, 0
  )
  outline.debug(
    "state",
    function (state)
      return tostring(state)
    end,
    components.state.stateMachines.patato.currentState,
    0.5, 0.5, 0.5
  )
  outline.debug(
    "hurtFallHeight",
    function (hurtFallHeight)
      return tostring(hurtFallHeight)
    end,
    components.state.collisionBoxes.patato.hurtFallHeight,
    0.8, 0.3, 0.3
  )
  outline.debug(
    "camera",
    function (position)
      return string.format("%.2f, %.2f", position.x, position.y)
    end,
    components.state.positions["my camera"],
    0.8, 0.4, 0.8
  )
  outline.debug(
    "spawned",
    function (t)
      local s = {}
      for k, v in pairs(t or {}) do
        s[#s + 1] = k
      end
      return tostring(#s)
    end,
    components.state.spawned,
    0.5, 0.5, 0.5
  )
end
