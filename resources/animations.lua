-- Animation = {frames, loop}
-- Frame = {sprite, duration, attackBox}
-- AttackBox = {x, y, width, height}

return {
  patato = {
    standing = {{{1, 1}}, false},
    walking = {{{2, 0.1}, {3, 0.1}, {4, 0.1}, {3, 0.1}}, true},
    startingJump = {{{1, 0.04}}, false},
    jumping = {{{4, 1}}, false},
    crouching = {{{5, 1}}, false},
    crouchWalking = {{{6, 0.1}, {7, 0.1}, {8, 0.1}, {7, 0.1}}, true},
    standingAttackingFlySwat = {{{9, 0.03}, {10, 0.1}, {9, 0.05}}, false},
    crouchingingAttackingFlySwat = {{{11, 0.1}, {12, 0.1}, {11, 0.1}}, false},
    climbingIdle = {{{17, 1}}, false},
    climbingUp = {{{18, 0.1}, {17, 0.1}, {16, 0.1}, {17, 0.1}}, true},
    climbingDown = {{{16, 0.1}, {17, 0.1}, {18, 0.1}, {17, 0.1}}, true},
    climbingStartingJump = {{{17, 0.04}}, false},
    climbingAttackingFlySwat = {{{19, 0.1}, {20, 0.1}, {19, 0.1}}, false},
    flyingHurt = {{{14, 1}}, false},
    lyingDown = {{{15, 1}}, false},
    gettingUp = {{{5, 0.1}}, false},
    hit = {{{13, 1}}, false},
  },
  bee = {
    flying = {{{21, 0.05}, {22, 0.05}}, true}
  }
}