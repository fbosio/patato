local resources = require "resources"

local M = {}

M.sounds = resources.sounds

M.physics = {
  gravity = 5000
}

M.inputs = {
  keyboard = {
    left2 = "j",
    right2 = "l",
    up2 = "i",
    down2 = "k",
    start = "return",
    message = "m",
    jump = "space"
  },
  joystick = {
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
}

M.entities = {
  patato = {
    flags = {
      "controllable",
      "collector",
      "solid",
      "gravitational",
      "climber"
    },
    collisionBox = {20, 120, 40, 120},
    impulseSpeed = {
      walk = 500,
      jump = 1500,
      climb = 200,
      climbJump = 700
    },
    resources = resources.patato,
  },
  bee = {
    flags = {"controllable"}
  },
  bottles = {
    flags = {"collectable"},
    collisionBox = {15, 45, 35, 45}
  },
  camera = {
    flags = {"camera"}
  },
  cameraBounds = {
    flags = {"limiter"}
  },
  cameraWindow = {
    flags = {"window"},
    collisionBox = {100, 100, 200, 200}
  },
  soilSurfaces = {
    collideable = "rectangle",
  },
  soilSlopes = {
    collideable = "triangle",
  },
  trellises = {
    flags = {"trellis"}
  },
  gardenArtwork = {
    resources = resources.levels.garden
  },
  secretLevelArtwork = {
    resources = resources.levels.secretLevel
  },
  background = {
    resources = resources.background
  },
  mainMenu = {
    flags = {"controllable"},
    menu = {
      options = {"Start", "Show message", "Secret level"},
    },
  }
}
M.entities.patato.resources.sprites.scale = 2
M.entities.background.resources.sprites.depth = 3
M.entities.background.resources.sprites.tiled = true

M.levels = {
  garden = {
    cameraBounds = {0, 0, 1000, 1000},
    background = {0, 0},
    gardenArtwork = {0, 0},
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
    soilSurfaces = {
      {200, 250, 300, 350},  -- block: x1, y1, x2, y2
      {100, 450, 700, 350},
      {200, 450, 300, 550},
      {300, 80, 500},  -- cloud: x1, y1, x2
      {-10, -135, 0, 600}
    },
    soilSlopes = {
      {100, 90, 20, 200},
      {100, 350, 200, 250},
      {400, 350, 300, 250},
      {100, 450, 200, 550},
      {400, 450, 300, 550},
    },
    trellises = {420, 20, 680, 370},
  },
  secretLevel = {
    secretLevelArtwork = {0, 0},
    patato = {200, 500},
    soilSurfaces = {20, 540, 400, 600},
  },
}
M.firstLevel = "garden"

return M
