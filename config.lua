local M = {}

M.keys = {
  left2 = "j",
  right2 = "l",
  up2 = "i",
  down2 = "k",
  start = "z"
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
      options = {"Start", "Show message", "Drink coffee", "Get up"},
    }
  }
}

M.levels = {
  firstLevel = {
    patato = {100, 287},
    bee = {300, 287}
  },
  first = "firstLevel"
}

return M
