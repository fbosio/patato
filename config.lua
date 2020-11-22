world = {
  gravity = 5000,
}

keys = {
  ["left"] = "a",
  ["right"] = "d",
}

sprites = "resources/sprites/patato.png"

entities = {
  ["patato"] = {
    input = {
      ["left"] = "left",
      ["right"] = "right",
    },
    impulseSpeed = {
      walk = 400,
      crouchWalk = 200,
      jump = 1200,
      climb = 400,
    },
    sprites = {
      {1, 1, 137, 266, 72.35, 256.5},
      {138, 1, 205, 251, 96.35, 251.5},
      {343, 1, 134, 282, 55.349999999999994, 271.5},
      {477, 1, 190, 264, 101.35, 259.5},
      {667, 1, 114, 151, 46.349999999999994, 138.5},
      {781, 1, 232, 165, 132.35, 146.5}, 
      {1, 283, 209, 162, 106.35, 146.5},
      {210, 283, 225, 159, 118.35, 144.5},
      {435, 283, 117, 270, 53.349999999999994, 259.5},
      {552, 283, 211, 264, 51.349999999999994, 249.5},
      {763, 283, 112, 160, 39.349999999999994, 141.5},
      {1, 553, 205, 154, 30.349999999999994, 138.5},
      {206, 553, 148, 280, 51.349999999999994, 261.5},
      {354, 553, 228, 127, 110.35, 197.5},
      {582, 553, 300, 106, 134.35, 55.5},
      {1, 833, 145, 261, 62.349999999999994, 246.5},
      {146, 833, 142, 249, 61.349999999999994, 247.5},
      {288, 833, 145, 261, 65.35, 246.5},
      {433, 833, 164, 259, 67.35, 255.5},
      {597, 833, 253, 257, 66.35, 249.5},
      {850, 833, 32, 32, 13.349999999999994, 29.5},
      {882, 833, 35, 18, 17.349999999999994, 16.5}
    },
    animations = {
      standing = {{{1, 1}}, false},
      walking = {{{2, 0.1}, {3, 0.1}, {4, 0.1}, {3, 0.1}}, true},
      startingJump = {{{1, 0.04}}, false},
      jumping = {{{4, 1}}, false},
      crouching = {{{5, 1}}, false},
      crouchWalking = {{{6, 0.1}, {7, 0.1}, {8, 0.1}, {7, 0.1}}, true},
      standAttackingFlySwat = {{{9, 0.03}, {10, 0.1}, {9, 0.05}}, false},
      crouchAttackingFlySwat = {{{11, 0.03}, {12, 0.1}, {11, 0.05}}, false},
      climbingIdle = {{{17, 1}}, false},
      climbingUp = {{{18, 0.1}, {17, 0.1}, {16, 0.1}, {17, 0.1}}, true},
      climbingDown = {{{16, 0.1}, {17, 0.1}, {18, 0.1}, {17, 0.1}}, true},
      climbingStartingJump = {{{17, 0.04}}, false},
      climbAttackingFlySwat = {{{19, 0.03}, {20, 0.1}, {19, 0.05}}, false},
      flyingHurt = {{{14, 1}}, false},
      lyingDown = {{{15, 1}}, false},
      gettingUp = {{{5, 0.1}}, false},
      hit = {{{13, 1}}, false},
    },
  },
}

levels = {
  ["test level"] = {
    ["patato"] = {0, 0},
  },
}