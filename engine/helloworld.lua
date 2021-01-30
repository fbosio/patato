local M = {}

function M.load(entityTagger)
  M.entityTagger = entityTagger
  M.loaded = true
end

function M.update(components, commands)
  if not M.loaded then return end

  local player = M.entityTagger.getId("player")
  local velocity = components.velocity[player]
  local impulseSpeed = components.impulseSpeed[player]
  if commands.hold.left and not commands.hold.right then
    velocity.x = -1
  elseif commands.hold.right and not commands.hold.left then
    velocity.x = 1
  else
    velocity.x = 0
  end
  if commands.hold.up and not commands.hold.down then
    velocity.y = -1
  elseif commands.hold.down and not commands.hold.up then
    velocity.y = 1
  else
    velocity.y = 0
  end
  local norm = math.sqrt(velocity.x^2 + velocity.y^2)
  if norm ~= 0 then
    velocity.x = velocity.x / norm * impulseSpeed.walk
    velocity.y = velocity.y / norm * impulseSpeed.walk
  end
end

return M
