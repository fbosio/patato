local M = {}

M.garden = {
  sprites = {
    image = "resources/images/garden.png",
    quads = {
      {10, 135, 710, 735}
    },
    depth = 2
  },
  animations = {
    {1, 1}
  }
}
M.secretLevel = {
  sprites = {
    image = "resources/images/secretLevel.png",
    quads = {
      {-20, -540, 380, 60}
    },
    depth = 2
  },
  animations = {
    {1, 1}
  }
}

return M
