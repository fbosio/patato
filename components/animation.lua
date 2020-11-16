local box = require "components.box"
local M = {}


-- Constants
local scale = 0.5
M.scale = scale  -- export


-- Animation Clip
local function createAnimationFrames(framesData, sprites, spriteSheet)
  local frames = {}
  for i, frame in ipairs(framesData) do
    local x, y, width, height, originX, originY = unpack(sprites[frame[1]])
    local attackBox = frame[3]
    frames[#frames + 1] = {
      quad = love.graphics.newQuad(x, y, width, height,
                                   spriteSheet:getDimensions()),
      origin = {x = -originX*scale, y = -originY*scale},
      duration = frame[2],
      attackBox = attackBox and box.AttackBox:new{
        x = attackBox[1]*scale,
        y = attackBox[2]*scale,
        width = attackBox[3]*scale,
        height = attackBox[4]*scale
      }
    }
  end
  return frames
end


local function createAnimations(animationsData, sprites, spriteSheet)
  local animations = {}

  for animationName, animationData in pairs(animationsData) do
    local newAnimation = {
      frames = createAnimationFrames(animationData[1], sprites, spriteSheet),
      looping = animationData[2]
    }

    function newAnimation:duration()
      local result = 0
      for _, frame in ipairs(self.frames) do
        result = result + frame.duration
      end
      return result
    end

    animations[animationName] = newAnimation
  end

  return animations
end


M.AnimationClip = {
  animations = nil,
  currentAnimationName = nil,
  currentTime = 0,
  facingRight = true,
  playing = true,
  _done = false
}

function M.AnimationClip:new(o)
  o = o or {}
  setmetatable(o, self)
  o.animations = createAnimations(o.animationsData, o.spritesData, o.spriteSheet)
  o.animationsData = nil
  o.spritesData = nil
  o.spriteSheet = nil
  self.__index = self

  return o
end

function M.AnimationClip:currentFrameNumber()
  local timeSpent = 0
  local currentAnimation = self.animations[self.currentAnimationName]
  for frameNumber, frame in ipairs(currentAnimation.frames) do
    timeSpent = timeSpent + frame.duration
    if timeSpent > self.currentTime then
      return frameNumber
    end
  end
  return #currentAnimation.frames
end

function M.AnimationClip:setAnimation(animationName)
  if self.animations[animationName]
      and self.currentAnimationName ~= animationName then
    self.currentAnimationName = animationName
    self.currentTime = 0
    self.playing = true
    self._done = false
  end
end

function M.AnimationClip:done()
  return self._done
end


M.DummyAnimationClip = {
  stateMachine = nil
}

function M.DummyAnimationClip:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  return o
end

function M.DummyAnimationClip:setAnimation() end

function M.DummyAnimationClip:done()
  return self.stateMachine.stateTime == 0
end


return M
