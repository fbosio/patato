local M = {}

function M.update(commands, sfx, t)
  if t.climber.trellis then
    if commands.hold.left and not commands.hold.right then
      t.velocity.x = -t.impulseSpeed.climb
      t.animation.name = "climbingMove"
    elseif commands.hold.right and not commands.hold.left then
      t.velocity.x = t.impulseSpeed.climb
      t.animation.name = "climbingMove"
    else
      t.velocity.x = 0
    end
    if commands.hold.up and not commands.hold.down then
      t.velocity.y = -t.impulseSpeed.climb
      t.animation.name = "climbingMove"
    elseif commands.hold.down and not commands.hold.up then
      t.velocity.y = t.impulseSpeed.climb
      t.animation.name = "climbingMove"
    else
      t.velocity.y = 0
    end
    if not commands.hold.left and not commands.hold.right
        and not commands.hold.up and not commands.hold.down then
      t.animation.name = "climbingIdle"
    end
  else
    if t.velocity.y == 0 and t.animation.name == "jumping" then
      sfx.footstep:play()
    end
    if commands.hold.left and not commands.hold.right then
      t.velocity.x = -t.impulseSpeed.walk
      t.animation.flipX = true
      t.animation.name = t.velocity.y == 0 and "walking" or "jumping"
    elseif commands.hold.right and not commands.hold.left then
      t.velocity.x = t.impulseSpeed.walk
      t.animation.flipX = false
      t.animation.name = t.velocity.y == 0 and "walking" or "jumping"
    else
      t.velocity.x = 0
      t.animation.name = t.velocity.y == 0 and "standing" or "jumping"
    end
    if commands.press.up or commands.press.down then
      t.climber.climbing = true
    end
  end
  if commands.press.jump then
    if t.climber.climbing then
      t.climber.climbing = false
      t.gravitational.enabled = true
    end
    if t.climber.trellis or t.velocity.y == 0 then
      t.animation.name = "jumping"
      t.velocity.y = -t.impulseSpeed.jump
    end
  end
end

return M
