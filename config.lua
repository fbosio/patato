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
  message = "m",
  jump = "space"
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
    input = true,
    collector = true,
    collisionBox = {20, 120, 40, 120},
    animations = {
      walking = {2, 0.1, 3, 0.1, 4, 0.1, 3, 0.1, true},
      standing = {1, 1, false} -- {spr1, t1, spr2, t2, ..., looping}
    },
    solid = true,
    gravitational = true,
    climber = true,
    impulseSpeed = {
      climb = 200,
      climbJump = 700
    }
  },
   bee = {
     input = true
   },
  bottles = {
    collectable = true,
    collisionBox = {15, 45, 35, 45},
    animations = {
      idle = {5, 1, false}
    }
  },
  surfaces = {
    collideable = "rectangle"
  },
  slopes = {
    collideable = "triangle"
  },
  trellises = {
    trellis = true
  },
  mainMenu = {
    input = {
      menuPrevious = "up",
      menuNext = "down",
      menuSelect = "start"
    },
    menu = {
      options = {"Start", "Show message", "Secret level"},
    },
  }
}

M.levels = {
  garden = {
    patato = {250, 100},
    bee = {450, 105},
    bottles = {
      {325, 80},
      {385, 80},
      {445, 80},
      {505, 80},
      {565, 80},
      {600, 500},
    },
    surfaces = {
      {200, 250, 300, 350},  -- block: x1, y1, x2, y2
      {100, 450, 700, 350},
      {200, 450, 300, 550},
      {300, 80, 500}  -- cloud: x1, y1, x2
    },
    slopes = {
      {100, 90, 20, 200},
      {100, 350, 200, 250},
      {400, 350, 300, 250},
      {100, 450, 200, 550},
      {400, 450, 300, 550},
    },
    trellises = {420, 20, 680, 200},
  },
  secretLevel = {
    patato = {200, 500},
    surfaces = {20, 540, 400, 600},
  },
}
M.firstLevel = "garden"

return M
