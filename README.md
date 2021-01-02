# Patato Man
A platform adventure video game, ported with [Löve2D](https://love2d.org/).

[![test](https://github.com/fbosio/patato/workflows/test/badge.svg)](https://github.com/fbosio/patato/actions)


## Engine
In its simplest form, the engine is used like follows.

Create a `main.lua` file along with the `engine` directory.
```lua
local engine = require "engine"

function love.load()
  engine.load()
end

function love.update(dt)
  engine.update(dt)
end

function love.draw()
  engine.draw()
end
```

After running `love .` in the directory that contains those files, a window with one character, drawn as a point, is loaded.
The character movement is controlled by the AWSD keys by default.

Next to the drawn point, there is a text that uniquely identifies it.
The identifier is called an **entity**.

### Configuration file
Create a `config.lua` file along with `main.lua` and `engine/`.
**The file must be non empty**, because is loaded as a module.
The engine displays an error if `config.lua` is empty or lacks a `return M` statement, where `M` is the engine module table.

In its simplest form, `config.lua` looks like this.
```lua
local M = {}

return M
```
When `main.lua` is run with [Löve2D](https://love2d.org/) using this configuration, an empty window is opened.
Keep reading for less trivial examples.

### Inputs
Let's create a game with one player.
```lua
local M = {}

M.entities = {
  myPlayer = {input = true}
}

return M
```

At this point, the engine does not know what to do with `myPlayer` when the user gives input to it, like pressing some keys of the keyboard for example.
_Inputs need to be set_ first in the `main.lua` file.
```lua
local engine = require "engine"

function love.load()
  engine.load()

  engine.setInputs("myPlayer", {
    walkLeft = engine.command{key = "left"},
    walkRight = engine.command{key = "right"},
    walkUp = engine.command{key = "up"},
    walkDown = engine.command{key = "down"},
    stopWalkingHorizontally = engine.command{
      keys = {"left", "right"},
      release = true
    },
    stopWalkingVertically = engine.command{
      keys = {"up", "down"},
      release = true
    }
  })
end

function love.update(dt)
  engine.update(dt)
end

function love.draw()
  engine.draw()
end
```

`engine.setInputs` receives two arguments.
1. An entity name that has an `input` field set to `true` in `config.lua` (`"myPlayer"`, in this case).
2. A table with commands. A **command** is just a bunch of keys with some options associated to it. The function `engine.command` defines a command from a table that has a string `key` or a table with several `keys`. The `release = true` argument is just a way to tell the engine that it needs to check when the key is released instead of pressed.
   
Now the character can be moved with the AWSD keys.
This setup is, in fact, the same that the engine takes by default when it finds no `config.lua` file.

The `key` and `keys` arguments of `engine.command` state that `"left"` and `"right"` must be pressed in order to make the character respectively walk to the left or to the right. But that is actually achieved by pressing respectively the A and D keys.

`engine.command` does not care about the _actual_ keys of the keyboard, or joystick buttons, or whatever. It just needs _references_ to those things, like the `"left"` and `"right"` strings used above, which are called **virtual inputs**. The A and D keys above are called **physical inputs**.

The engine associates the `"left"`, `"up"`, `"down"` and `"right"` inputs with the AWSD physical keys by default.

### More options
Let's make the player walk slower and just horizontally when the user presses the J and L keys of the keyboard.
The new `config.lua` looks like this.
```lua
local M = {}

M.keys = {
  left = "j",
  right = "l"
}

M.entities = {
  myPlayer = {
    input = true,
    impulseSpeed = {walk = 1000}
  }
}

return M
```

Remember that inputs need to be set in `main.lua`.
```lua
local engine = require "engine"

function love.load()
  engine.load()

  engine.setInputs("myPlayer", {
    walkLeft = engine.command{key = "left"},
    walkRight = engine.command{key = "right"},
    stopWalkingHorizontally = engine.command{
      keys = {"left", "right"},
      release = true
    }
  })
end

function love.update(dt)
  engine.update(dt)
end

function love.draw()
  engine.draw()
end
```

The `keys` table of the configuration maps virtual inputs (`left` and `right`) with physical inputs (`"j"` and `"l"`, respectively).

`impulseSpeed` defines how fast the player moves. Walk speed was implicitly defined by the engine in the above examples. It is now explicitly defined as `1000` by the `walk` field in the `impulseSpeed` table in `config.lua`.

`input` and `impulseSpeed` are **components** of `myPlayer`.

### Menu
For the engine, a menu is just another entity with a `menu` component attached to it.
Here's an example `config.lua` that defines a menu with two options:

1. Start game.
2. Print a message on screen.

```lua
local M = {}

M.entities = {
  myPlayer = {input = true},
  mainMenu = {
    input = true,
    menu = {
      options = {"Start", "Show message"},
    }
  }
}

return M
```

The `input` component is obviously mandatory for the `mainMenu` entity: its options need to be selected through user input.

In order for the menu to do actually _something_, a more elaborated `main.lua` is required.
```lua
local engine = require "engine"
local elapsed, showingMessage


function love.load()
  engine.load()

  engine.setInputs("myPlayer", {
    walkLeft = engine.command{key = "left"},
    walkRight = engine.command{key = "right"},
    stopWalkingHorizontally = engine.command{
      keys = {"left", "right"},
      release = true
    }
  })
  
  engine.setInputs("mainMenu", {
    menuNext = engine.command{key = "down", oneShot = true},
    menuPrevious = engine.command{key = "up", oneShot = true},
    menuSelect = engine.command{key = "start", oneShot = true}
  })
  engine.setMenuOptionEffect("mainMenu", 1, function ()
    engine.startGame()
  end)
  engine.setMenuOptionEffect("mainMenu", 2, function ()
    elapsed = 0
    showingMessage = true
  end)
end

function love.update(dt)
  engine.update(dt)

  if elapsed then
    elapsed = elapsed + dt
    if elapsed > 1 then
      elapsed = nil
      showingMessage = false
    end
  end
end

function love.draw()
  engine.draw()

  if showingMessage then
    love.graphics.print("Get up for the down stroke!", 0, 0)
  end
end

function love.keypressed(key)
  engine.keypressed(key)
end
```

An option may be now selected by pressing the W, S and Return/Enter keys.
These are the default physical keys.
Note that the `"mainMenu"` commands have the `oneShot = true` argument.
This makes the `keypressed` callback mandatory for navigating through the menu options: _omitting it, user input is not detected_.

Option effects are declared inside the `love.load` callback by using `setMenuOptionEffect`. It receives three arguments.

1. The menu entity name: `"mainMenu"`, in this case.
2. The option number, in the order stated in `config.lua`.
   In this case, `1` represents the `"Start"` option, and `2`, the `"Show message"` option.
3. A function that is called when the given option is chosen in the menu.

The example `main.lua` file has two effects declared.

1. The first option _starts_ the game, i.e., it hides the menu and shows the `player` that you can move.
2. The other option shows a message and hides it after one second.

If you prefer the Spacebar for selecting the options, change `config.lua`.
```lua
local M = {}

M.keys = {
  start = "space"  -- now Spacebar is used to select an option
}

M.entities = {
  myPlayer = {input = true},
  mainMenu = {
    input = true,
    menu = {
      options = {"Start", "Show message"},
    }
  }
}

return M
```

### Levels
The following `config.lua` declares two levels.
```lua
local M = {}

M.entities = {
  myPlayer = {input = true}
}

M.levels = {
  quest = {
    myPlayer = {700, 100}
  },
  minigame = {
    myPlayer = {100, 500}
  }
}
M.firstLevel = "quest"

return M
```

The `firstLevel` string states which field of the `levels` table corresponds to the level that is loaded at start by default.
If `firstLevel` is changed to `"minigame"` instead of `"quest"`, the player appears in the opposite corner of the window.

The level can be selected from a menu, too.
```lua
local M = {}

M.entities = {
  myPlayer = {input = true},
  mainMenu = {
    input = true,
    menu = {
      options = {"Start quest", "Play minigame"}
    }
  }
}

M.levels = {
  quest = {
    myPlayer = {700, 100}
  },
  minigame = {
    myPlayer = {100, 500}
  }
}
M.firstLevel = "quest"

return M
```

But, in this case, proper callbacks are required in the `main.lua` file.
```lua
local engine = require "engine"


function love.load()
  engine.load()

  engine.setInputs("myPlayer", {
    walkLeft = engine.command{key = "left"},
    walkRight = engine.command{key = "right"},
    stopWalkingHorizontally = engine.command{
      keys = {"left", "right"},
      release = true
    }
  })
  
  engine.setInputs("mainMenu", {
    menuNext = engine.command{key = "down", oneShot = true},
    menuPrevious = engine.command{key = "up", oneShot = true},
    menuSelect = engine.command{key = "start", oneShot = true}
  })
  engine.setMenuOptionEffect("mainMenu", 1, function ()
    engine.startGame()
  end)
  engine.setMenuOptionEffect("mainMenu", 2, function ()
    engine.startGame("minigame")
  end)
end

function love.update(dt)
  engine.update(dt)
end

function love.draw()
  engine.draw()
end

function love.keypressed(key)
  engine.keypressed(key)
end
```

Selecting the first menu option loads the first level: there is no need to pass `"quest"` to the `startGame` function explicitly (although is totally allowed).
On the other hand, since `"minigame"` is not declared as the first level by the `firstLevel` field in `config.lua`, it is not loaded by default, so `"minigame"` must be passed to `startGame` in that case.

### Collectables
There are four things needed in order to add this behavior to the game.

1. A `collector` component.
2. A `collectable` component.
3. Two `collisionBox` components.
4. A collectable "effect", i.e., a callback.

The components are declared in `config.lua`.
```lua
local M = {}

M.entities = {
  myPlayer = {
    input = true,
    collector = true,
    collisionBox = {15, 35, 30, 70}
  },
  coin = {
    collectable = true,
    collisionBox = {5, 5, 10, 10}
  }
}

M.levels = {
  myLevel = {
    myPlayer = {260, 300},
    coin = {
      {440, 300},
      {460, 300},
      {480, 300},
      {500, 300},
      {520, 300}
    }
  }
}

return M
```

The callbacks are defined in `main.lua`.
```lua
local engine = require "engine"
local score


function love.load()
  engine.load()

  engine.setInputs("myPlayer", {
    walkLeft = engine.command{key = "left"},
    walkRight = engine.command{key = "right"},
    stopWalkingHorizontally = engine.command{
      keys = {"left", "right"},
      release = true
    }
  })
  
  score = 0
  engine.setCollectableEffect("coin", function ()
    score = score + 1
  end)
end

function love.update(dt)
  engine.update(dt)
end

function love.draw()
  engine.draw()

  love.graphics.print(score, 0, 0)
end
```
In this case, when each coin is _collected_ by the player, the `score` is increased by one.


### Architecture

[![Modules Diagram](http://www.plantuml.com/plantuml/png/VOvH2W8n34J_UugUO8-mx5L2TooBJReqgI3YtLMia5NmCs_2crdKg5dd4bBblGh4OgaNk3DLEMqvx9JEb14XUHF4MuZ-XPbazKYlQc3rg45hRmbCGXdj6CcATcH6-VLr3s6uuZJDxt5Vfh_1sFyRpP-6KUuqovDqBWy0)](http://www.plantuml.com/plantuml/uml/VOvH2W8n34J_UugUO8-mx5L2TooBJReqgI3YtLMia5NmCs_2crdKg5dd4bBblGh4OgaNk3DLEMqvx9JEb14XUHF4MuZ-XPbazKYlQc3rg45hRmbCGXdj6CcATcH6-VLr3s6uuZJDxt5Vfh_1sFyRpP-6KUuqovDqBWy0)

[![Controller Maps Diagram](http://www.plantuml.com/plantuml/png/TP2_JiCm4CRtUuflX8XswDwgEuY1Dx1IbvgUxIY-12AKTyUNs58bbCdw_lX-fpidCRqCdicR3dSx9VmIq3IZoxRXLpir3Owdx7ItARcsMBd3zYg0PYQhtdtUP56NaXqMzLMpWoecp0H5kT0DKc6c5HV3k_6sm2g-ihuDtz-KbzCLNCmF7PtDbQ7Js-Yx66mGj3587vbjhnY5hfnDQd7-4wz3M18yZIz8pnZtFpXYb_RQWWsNnsssFppsPvg9bdllJkKOj3vgb4NfdBk3vpy0)](http://www.plantuml.com/plantuml/uml/TP2_JiCm4CRtUuflX8XswDwgEuY1Dx1IbvgUxIY-12AKTyUNs58bbCdw_lX-fpidCRqCdicR3dSx9VmIq3IZoxRXLpir3Owdx7ItARcsMBd3zYg0PYQhtdtUP56NaXqMzLMpWoecp0H5kT0DKc6c5HV3k_6sm2g-ihuDtz-KbzCLNCmF7PtDbQ7Js-Yx66mGj3587vbjhnY5hfnDQd7-4wz3M18yZIz8pnZtFpXYb_RQWWsNnsssFppsPvg9bdllJkKOj3vgb4NfdBk3vpy0)
