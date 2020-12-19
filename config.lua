local M = {}

M.keys = {
  left2 = "j",
  right2 = "l",
  up2 = "i",
  down2 = "k",
  start = "return",
}

M.entities = {
  patato = {
    input = {
    },
    collector = true,
    collisionBox = {-15, -35, 30, 70},
  },
  bee = {
    input = {
      walkLeft = "left2",
      walkRight = "right2",
    }
  },
  mainMenu = {
    input = {},
    menu = {
      options = {"Start", "Show message", "Secret level"},
    },
  }
}

M.levels = {
  garden = {
    patato = {100, 287},
    bee = {300, 287},
  },
  secretLevel = {
    patato = {200, 500},
  },
}
M.firstLevel = "garden"

return M
