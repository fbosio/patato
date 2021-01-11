local resources = require "resources"

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

M.joystick = {
  hats = {
    left = "l",
    right = "r",
    up = "u",
    down = "d"
  },
  buttons = {
    jump = 3,
    message = 2,
    start = 10
  }
}

M.spriteSheet = "resources/patato.png"
M.spriteScale = 2
M.sprites = resources.sprites

M.entities = {
  patato = {
    flags = {
      "controllable",
      "collector",
      "solid",
      "gravitational",
      "climber"
    },
    collisionBox = {20, 120, 40, 115},
    animations = resources.animations,
    impulseSpeed = {
      jump = 1500,
      climb = 200,
      climbJump = 700
    }
  },
  bee = {
    flags = {"controllable"}
  },
  bottles = {
    flags = {"collectable"},
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
    flags = {"trellis"}
  },
  mainMenu = {
    flags = {"controllable"},
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
    trellises = {420, 20, 680, 370},
  },
  secretLevel = {
    patato = {200, 500},
    surfaces = {20, 540, 400, 600},
  },
}
M.firstLevel = "garden"

return M
