local components = require "components"
local box = require "components.box"
local levels = require "levels"
local players = require "systems.players"
local outline = require "outline"
local camera = require "systems.camera"
local systems = require "systems"
local items = require "systems.items"
local terrain = require "systems.terrain"

function love.load()
  local currentLevel = levels.level[levels.first]
  local playerName = "patato"
  components.state = {
    collisionBoxes = {
      [playerName] = box.CollisionBox:new{width=50, height=100}
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
      [playerName] = {walk=400, jump=1200, climb=400},
    },
    collectors = {
      [playerName] = true
    }
  }

  -- Move to init.load
  components.state.currentLevel = currentLevel

  terrain.load(components.state)
  players.load(playerName, components.state)
  items.load(components.state)
  camera.load("my camera", playerName, components.state)
end

function love.update(dt)
  systems.update(components.state, dt)
end

function love.draw()
  outline.draw(components.state, camera.positions(components.state))

  outline.debug(
    "mouse",
    function ()
      return love.mouse.getX() .. ", " .. love.mouse.getY()
    end,
    nil,
    1, 1, 1
  )
  outline.debug(
    "player",
    function (position)
      return math.floor(position.x) .. ", " .. math.floor(position.y)
    end,
    components.state.positions.patato,
    1, 1, 0
  )
  outline.debug(
    "health",
    function (health)
      return health
    end,
    components.state.living.patato.health,
    1, 0, 0
  )
end
