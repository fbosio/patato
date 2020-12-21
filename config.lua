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
    collisionBox = {15, 70, 30, 70},
  },
  bee = {
    input = {
      walkLeft = "left2",
      walkRight = "right2",
    }
  },
  bottle = {
    collectable = true,
    collisionBox = {5, 5, 10, 10}
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
    bottle = {
      {325, 360},
      {345, 360},
      {365, 360},
      {385, 360},
      {405, 360},
      {600, 500},
    }
  },
  secretLevel = {
    patato = {200, 500},
  },
}
M.firstLevel = "garden"

return M
