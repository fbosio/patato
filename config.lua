local M = {}

M.keys = {
  left2 = "j",
  right2 = "l",
  up2 = "i",
  down2 = "k",
  start = "return"
}

M.entities = {
  patato = {
    input = {
    }
  },
  bee = {
    input = {
      walkLeft = "left2",
      walkRight = "right2"
    }
  },
  mainMenu = {
    input = {},
    menu = {
      options = {"Start", "Show message", "Secret level"},
    }
  }
}

M.levels = {
  firstLevel = {
    patato = {100, 287},
    bee = {300, 287}
  },
  secretLevel = {
    patato = {200, 500}
  },
  first = "firstLevel"
}

return M
