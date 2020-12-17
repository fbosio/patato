local M = {}

M.keys = {
  left2 = "j",
  right2 = "l",
  up2 = "i",
  down2 = "k"
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
    input = {
      menuPrevious = "up",
      menuNext = "down"
    },
    menu = {
      options = {"Start", "Show message", "Drink coffee", "Get up"}
    }
  }
}

return M
