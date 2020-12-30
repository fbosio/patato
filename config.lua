local M = {}

M.physics = {
  gravity = 5000
}

M.keys = {
  left2 = "j",
  right2 = "l",
  up2 = "i",
  down2 = "k",
  start = "return",
  message = "m"
}

M.spriteSheet = "resources/sprites/patato.png"
M.spriteScale = 0.5
M.sprites = {
  {1, 1, 137, 266, 72.35, 256.5}, -- {x, y, width, height, originX, originY}
  {138, 1, 205, 251, 96.35, 251.5},
  {343, 1, 134, 282, 55.349999999999994, 271.5},
  {477, 1, 190, 264, 101.35, 259.5},
  {917, 833, 61, 83, 28.349999999999994, 80.5}
}

M.entities = {
  patato = {
    input = {
      walkLeft = "left",
      walkRight = "right",
      walkUp = "up",
      walkDown = "down",
      showCustomMessage = "message"
    },
    collector = true,
    collisionBox = {20, 120, 40, 120},
--    animations = {
--      walking = {2, 0.1, 3, 0.1, 4, 0.1, 3, 0.1, true},
--      standing = {1, 1, false} -- {spr1, t1, spr2, t2, ..., looping}
--    },
    solid = true,
    -- gravitational = true
  },
   bee = {
     input = {
       walkLeft = "left2",
       walkRight = "right2",
     }
   },
  bottle = {
    collectable = true,
    collisionBox = {15, 45, 35, 45},
    animations = {
      idle = {5, 1, false}
    }
  },
  surface = {
    collideable = "rectangle"
  },
  slope = {
    collideable = "triangle"
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
    patato = {110, 239},
    bee = {450, 105},
    bottle = {
      {325, 80},
      {385, 80},
      {445, 80},
      {505, 80},
      {565, 80},
      {600, 500},
    },
    surface = {
      {170, 280, 255, 355},  -- block: x1, y1, x2, y2
      {255, 280, 340, 355},
      {170, 355, 255, 430},
      {255, 355, 340, 430},
      {300, 80, 600}  -- cloud: x1, y1, x2
    },
    slope = {
      {620, 230, 680, 170},
      {740, 230, 680, 170},
      {620, 230, 680, 290},
      {740, 230, 680, 290},
    }
  },
  secretLevel = {
    patato = {200, 500},
  },
}
M.firstLevel = "garden"

return M
