# Patato Man
A platform adventure video game, ported with [Löve2D](https://love2d.org/).

[![test](https://github.com/fbosio/patato/workflows/test/badge.svg)](https://github.com/fbosio/patato/actions)


## Engine
The engine has three functions, similar to those in [Löve2D](https://love2d.org/).

* `load()`
* `update(dt)`
* `draw()`

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
The character movement is controlled by the AWSD keys.

### Configuration file
Create a `config.lua` file along with `main.lua` and `engine/`.
**The file must be non empty**, because is loaded as a module.

* In its simplest form, the file looks like this.
  ```lua
  local M = {}

  return M
  ```
  When `main.lua` is run with [Löve2D](https://love2d.org/), an empty window is opened.
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
  - `playerOne` is moved by pressing the AWSD keys, because that is what the engine does by default.
  - `playerTwo` is moved only in the horizontal direction by pressing the `"left2"` and `"right2"` keys, which are mapped to the J and L physical keys of the keyboard by the `keys` table, defined above.
  - `impulseSpeed` defines how fast each player moves when the corresponding keys are pressed.
    + `playerOne` walk speed is implicitly defined by the engine.
    + `playerTwo` walk speed is explicitly defined as `100` by the `walk` field in the `impulseSpeed` table.


## Specs
| Game | Engine  |
|------|---------|
| Specific | General |
| Definitions | Statements |
| Keys | Actions |
|      | Controller |
| Entities | State |
| Speed impulses | Physics |
| "Hanging" components |  Required components |
| Levels | Load and use of resources |
| Sprites | Screen painting |
| Animations |  |
| | TEST |

[![Modules Diagram](http://www.plantuml.com/plantuml/png/VOv12i9G34JtEKLEq2D8hnA-uwVO92L91H7lhc31ZmkNC_DWtfmbKRkkr5mtDrZnwZSCiRbTbawRjAjqCAml1duGVv6yPq5ph0BfUpIec7G4FOaEYgVfzFduOVuFXyOCExzrNm00)](http://www.plantuml.com/plantuml/uml/VOv12i9G34JtEKLEq2D8hnA-uwVO92L91H7lhc31ZmkNC_DWtfmbKRkkr5mtDrZnwZSCiRbTbawRjAjqCAml1duGVv6yPq5ph0BfUpIec7G4FOaEYgVfzFduOVuFXyOCExzrNm00)

[![Controller Maps Diagram](http://www.plantuml.com/plantuml/png/TP2_JiCm4CRtUuflX8XswDwgEuY1Dx1IbvgUxIY-12AKTyUNs58bbCdw_lX-fpidCRqCdicR3dSx9VmIq3IZoxRXLpir3Owdx7ItARcsMBd3zYg0PYQhtdtUP56NaXqMzLMpWoecp0H5kT0DKc6c5HV3k_6sm2g-ihuDtz-KbzCLNCmF7PtDbQ7Js-Yx66mGj3587vbjhnY5hfnDQd7-4wz3M18yZIz8pnZtFpXYb_RQWWsNnsssFppsPvg9bdllJkKOj3vgb4NfdBk3vpy0)](http://www.plantuml.com/plantuml/uml/TP2_JiCm4CRtUuflX8XswDwgEuY1Dx1IbvgUxIY-12AKTyUNs58bbCdw_lX-fpidCRqCdicR3dSx9VmIq3IZoxRXLpir3Owdx7ItARcsMBd3zYg0PYQhtdtUP56NaXqMzLMpWoecp0H5kT0DKc6c5HV3k_6sm2g-ihuDtz-KbzCLNCmF7PtDbQ7Js-Yx66mGj3587vbjhnY5hfnDQd7-4wz3M18yZIz8pnZtFpXYb_RQWWsNnsssFppsPvg9bdllJkKOj3vgb4NfdBk3vpy0)
