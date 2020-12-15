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
      left = "left2",
      right = "right2"
    }
  }
}

return M
