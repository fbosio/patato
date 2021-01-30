--[[--
 Contains a callback for general use and specific functions that constitute its
 API.

 @module engine
]]

local config = love.filesystem.getInfo("config.lua") and require "config"
local entityTagger = require "engine.tagger"
local systems = require "engine.systems"
local helpers = require "engine.systems.helpers"
local handlers = require "engine.handlers"
local helloworld = require "engine.helloworld"


local M = {}

--[[--
 Callback

 The engine Swiss Army knife for communicating with
 [Löve2D](https://love2d.org/).

 @section callback
]]

local function load()
  local world = systems.load(love, entityTagger, config)
  
  for k, v in pairs(world) do
    M[k] = v
  end
  
  handlers.load(M)

  if not config then
    helloworld.load(entityTagger)
  end
end

local function update(dt)
  helloworld.update(M.gameState.components, M.gameState.hid.commands)
  systems.update(dt, M.gameState, M.resources, M.physics)
end

local function draw()
  systems.draw(M.gameState, M.resources, M.release)
end

--[[--
 All-in-one callback.
 
 Load, update, draw and handle [Löve2D events](https://love2d.org/wiki/Event)
 from the same place.

 @usage
  love.run = engine.run
]]
function M.run()
  load()
  if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
  if love.timer then love.timer.step() end
  
  local dt = 0
  
  return function()
    if love.event then
      love.event.pump()
      for name, a, b, c, d, e, f in love.event.poll() do
        if name == "quit" then
          if not love.quit or not love.quit() then
            return a or 0
          end
        end
        handlers[name](a, b, c, d, e, f)
        love.handlers[name](a, b, c, d, e, f)
      end
    end
  
    if love.timer then dt = love.timer.step() end
  
    if love.update then love.update(dt) end
    update(dt)
  
    if love.graphics and love.graphics.isActive() then
      love.graphics.origin()
      love.graphics.clear(love.graphics.getBackgroundColor())
  
      draw()
      if love.draw then love.draw() end
  
      love.graphics.present()
    end
  
    if love.timer then love.timer.sleep(0.001) end
  end
end


--[[--
 API

 Engine-specific functions

 @section api
]]

--[[--
 Hide menu and load a specific level of the game.

 Used often without arguments inside a callback when a menu entity that has a
 `"Start Game"` option, or similar, is defined in `config.lua`.

 @tparam[opt=config.firstLevel] string level
  Name of the level, as defined in `config.lua`.
 @usage
  -- In this case, "Start Game" is the option number 1 of the menu
  engine.gameState.menu.mainMenu = {
    function ()
      engine.startGame()
    end,
    function ()
      print("Hello, world!")
    end
  }
]]
function M.startGame(level)
  local components, inMenu = systems.reload(level, M.gameState.inMenu)
  M.gameState.components, M.gameState.inMenu = components, inMenu
end

--[[--
 Return components of an entity with their current status in the game.

 @tparam string entity Name of the entity, as defined in `config.lua`.
 @treturn table Components of the entity.
 @usage
  local engine = require "engine"

  love.run = engine.run

  function love.update()
    local player = engine.getComponents("player")
    -- "player" has "velocity" and "impulseSpeed" because it is "controllable"
    player.velocity.x = player.impulseSpeed.walk
  end
]]
function M.getComponents(entity)
  local id = entityTagger.getId(entity)
  return helpers.buildArguments(id, M.gameState.components)
end

return M
