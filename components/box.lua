local M = {}


-- Abstract class
M.Box = {
  x = 0,
  y = 0,

  -- Constructor arguments
  width = nil,
  height = nil
}

-- Constructor
function M.Box:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  return o
end

-- Object methods
function M.Box:left()
  return self.x - self.width/2
end

function M.Box:right()
  return self.x + self.width/2
end

function M.Box:top()
  return self.y - self.height
end

function M.Box:bottom()
  return self.y
end

function M.Box:center()
  return self.y - self.height/2
end

function M.Box:intersects(box)
  return self:left() <= box:right() and self:right() >= box:left()
         and self:top() <= box:bottom() and self:bottom() >= box:top()
end

-- Static method
function M.Box.translated (o, position)
  if position then
    x, y = position.x, position.y
  else
    x, y = 0, 0
  end

  local attributes = {}
  for k, v in pairs(o) do
    attributes[k] = v
  end
  attributes.x = x
  attributes.y = y

  return o:new(attributes)
end


-- Inherited classes
M.ItemBox = M.Box:new{
  width = 10,
  height = 10,

  effectAmount = 0,
}


M.GoalBox = M.Box:new{
  nextLevel = nil,  -- constructor argument
  width = 100,
  height = 100
}

-- Extended method
function M.GoalBox:translated(position)
  return M.Box.translated(self, position)
end


M.CollisionBox = M.Box:new{
  -- set by main load function
  maxFallSpeed = nil,
  -- set by control and terrain systems
  hurtFallHeight = false,
  -- set by control system
  climbing = false,
  -- set by terrain system
  slopeId = nil,
  reactingWithClouds = true,
  ladder = nil
}


M.AttackBox = M.Box:new()

-- Extended method
function M.AttackBox:translated(position, animationClip)
  local currentAnimation =
    animationClip.animations[animationClip.nameOfCurrentAnimation]
  local currentFrame =
    currentAnimation.frames[animationClip:currentFrameNumber()]
  local frameAttackBox = currentFrame.attackBox
  local offsetX = (animationClip.facingRight and 1 or -1) * frameAttackBox.x

  local box = M.Box.translated(self, position)
  box.x = box.x + offsetX
  box.y = box.y + frameAttackBox.y
  return box
end


return M
