local M = {}

M.entities = {
  player = {
    input = {
      walkLeft = "left",
      walkRight = "right",
      walkUp = "up",
      walkDown = "down"
    },
    collector = true,
    collisionBox = {15, 35, 30, 70}
  },
  coin = {
    collectable = true,
    collisionBox = {5, 5, 10, 10}
  }
}

M.levels = {
  myLevel = {
    player = {260, 300},
    coin = {
      {440, 300},
      {460, 300},
      {480, 300},
      {500, 300},
      {520, 300}
    }
  }
}

return M