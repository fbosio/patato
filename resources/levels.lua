local M = {}

M.garden = {
  spriteSheet = "resources/garden.png",
  sprites = {
    {10, 135, 710, 735}
  },
  animations = {
    {1, 1}
  }
}
M.secretLevel = {
  spriteSheet = "resources/secretLevel.png",
  sprites = {
    {-20, -540, 380, 60}
  },
  animations = {
    {1, 1}
  }
}

return M
