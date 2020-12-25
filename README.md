# Patato Man
A platform adventure video game, ported with [Löve2D](https://love2d.org/).

[![test](https://github.com/fbosio/patato/workflows/test/badge.svg)](https://github.com/fbosio/patato/actions)


## Engine
The engine has **events** and **public functions**.

* **Four events**, similar to those in [Löve2D](https://love2d.org/).
  - `load()`
  - `update(dt)`
  - `draw()`
  - `keypressed(key)`
* **Engine-specific functions**
  - `startGame(levelName)`
  - `setMenuOptionEffect(entity, index, callback)`
  - `setCollectableEffect(name, callback)`
  - `setAction(action, callback)`
  - `setOmissions(actions, callback)`

In its simplest form, the engine is used like follows.

Create a `main.lua` file along with the `engine` directory that contains the Game engine.
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

### Configuration file
Create a `config.lua` file along with `main.lua` and `engine/`.
**The file must be non empty**, because is loaded as a module.
The engine displays an error if `config.lua` is empty or lacks a `return M` statement, where `M` is the engine module table.

* In its simplest form, `config.lua` looks like this.
  ```lua
  local M = {}

  return M
  ```
  When `main.lua` is run with [Löve2D](https://love2d.org/) using this configuration, an empty window is opened.
* Game with one player.
   ```lua
  local M = {}
  
  M.entities = {
    myPlayer = {
      input = {}
    }
  }
  
  return M
  ```
  This is the same configuration that is used when no `config.lua` file is present.
* More options
  ```lua
  local M = {}

  M.keys = {
    left2 = "j",
    right2 = "l"
  }

  M.entities = {
    playerOne = {
      input = {
      }
    },
    playerTwo = {
      input = {
        walkLeft = "left2",
        walkRight = "right2"
      },
      impulseSpeed = {
        walk = 100
      }
    }
  }

  return M
  ```
  Now the game is loaded with two players in it.
  - `playerOne` is moved by pressing the AWSD keys, because that is what the engine does by default when an empty `input` table is declared.
  - `playerTwo` may be moved only in the horizontal direction because its `input` table has only the fields `walkLeft` and `walkRight` in it. This player is moved in the horizontal direction by pressing the `"left2"` and `"right2"` keys, which are mapped to the J and L physical keys of the keyboard by the `keys` table, defined above.
  - `impulseSpeed` defines how fast each player moves when the corresponding keys are pressed.
    + `playerOne` walk speed is implicitly defined by the engine.
    + `playerTwo` walk speed is explicitly defined as `100` by the `walk` field in the `impulseSpeed` table.

In `config.lua`, each field of the `entities` table is the name of what will be referred here as an **entity**.
In turn, each entity has tables associated to it, that will be called **components**.
So, in the latter case above, `playerOne` and `playerTwo` are entities, while `input`, and `impulseSpeed` are its components. 

### Menu
For the engine, a menu is just another entity with a `menu` component attached to it.
Here's an example `config.lua` that defines a menu with two options:

1. Start game.
2. Print a message on screen.

```lua
local M = {}

M.entities = {
  player = {
    input = {}
  },
  mainMenu = {
    input = {},
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

  -- setMenuOptionEffect(entity, index, callback)
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
These are the default keys.
Note that the `keypressed` callback is needed for navigating through the menu options: _omitting it, user input is not detected_.

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
  player = {
    input = {}
  },
  mainMenu = {
    input = {},
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
  player = {
    input = {}
  }
}

M.levels = {
  quest = {
    player = {700, 100}
  },
  minigame = {
    player = {100, 500}
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
  player = {
    input = {}
  },
  mainMenu = {
    input = {},
    menu = {
      options = {"Start quest", "Play minigame"}
    }
  }
}

M.levels = {
  quest = {
    player = {700, 100}
  },
  minigame = {
    player = {100, 500}
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

  -- setMenuOptionEffect(entity, index, callback)
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
  player = {
    input = {},
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
    player = {260, 300},
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

  score = 0
  -- setCollectableEffect(name, callback)
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

[![Modules Diagram](http://www.plantuml.com/plantuml/png/VOvH2i9034J_znHxWXwXz2fX7PTYavGaAuXuTnLRsYhucNdXpGmUPD5uIaLvLe54dlIAtLbKpcDDCvKBLMH87GNvdlBsuZSFiEyZWskp0YQX2ZiYES6EML1zVprIMbovw_hFaY_JVx2C_K7zsh2MRvhXbJIUdW00)](http://www.plantuml.com/plantuml/uml/VOvH2i9034J_znHxWXwXz2fX7PTYavGaAuXuTnLRsYhucNdXpGmUPD5uIaLvLe54dlIAtLbKpcDDCvKBLMH87GNvdlBsuZSFiEyZWskp0YQX2ZiYES6EML1zVprIMbovw_hFaY_JVx2C_K7zsh2MRvhXbJIUdW00)

[![Controller Maps Diagram](http://www.plantuml.com/plantuml/png/TP2_JiCm4CRtUuflX8XswDwgEuY1Dx1IbvgUxIY-12AKTyUNs58bbCdw_lX-fpidCRqCdicR3dSx9VmIq3IZoxRXLpir3Owdx7ItARcsMBd3zYg0PYQhtdtUP56NaXqMzLMpWoecp0H5kT0DKc6c5HV3k_6sm2g-ihuDtz-KbzCLNCmF7PtDbQ7Js-Yx66mGj3587vbjhnY5hfnDQd7-4wz3M18yZIz8pnZtFpXYb_RQWWsNnsssFppsPvg9bdllJkKOj3vgb4NfdBk3vpy0)](http://www.plantuml.com/plantuml/uml/TP2_JiCm4CRtUuflX8XswDwgEuY1Dx1IbvgUxIY-12AKTyUNs58bbCdw_lX-fpidCRqCdicR3dSx9VmIq3IZoxRXLpir3Owdx7ItARcsMBd3zYg0PYQhtdtUP56NaXqMzLMpWoecp0H5kT0DKc6c5HV3k_6sm2g-ihuDtz-KbzCLNCmF7PtDbQ7Js-Yx66mGj3587vbjhnY5hfnDQd7-4wz3M18yZIz8pnZtFpXYb_RQWWsNnsssFppsPvg9bdllJkKOj3vgb4NfdBk3vpy0)
