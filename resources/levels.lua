local M = {}

M.garden = {
  sprites = {
    image = "resources/garden.png",
    quads = {
      {10, 135, 710, 735}
    }
  },
  animations = {
    {1, 1}
  }
}
M.secretLevel = {
  sprites = {
    image = "resources/secretLevel.png",
    quads = {
      {-20, -540, 380, 60}
    }
  },
  animations = {
    {1, 1}
  }
}

return M
