local classic = require 'classic'

local Catch, super = classic.class('Catch', Env)

-- Constructor
function Catch:_init(opts)
  opts = opts or {}

  -- Difficulty
  self.difficulty = opts.difficulty or 'hard'

  -- Width and height
  self.size = opts.size or 8
  self.screen = torch.Tensor(1, self.size, self.size):zero()

  -- Player params/state
  self.player = {
    x = math.ceil(self.size / 2),
    width = opts.playerWidth or math.ceil(self.size / 4)
  }

  -- Ball params/state
  self.ball = {
    x = torch.random(self.size),
    y = 1
  }
  -- Trajectory
  self.ball.startX = self.ball.x
  self.ball.endX = self.difficulty == 'easy' and self.ball.startX or torch.random(self.size)
  self.ball.gradX = (self.ball.endX - self.ball.startX) / (self.size - 1)
end

-- 1 state returned, of type 'int', of dimensionality 1 x self.size x self.size, between 0 and 1
function Catch:getStateSpec()
  return {'int', {1, self.size, self.size}, {0, 1}}
end

-- 1 action required, of type 'int', of dimensionality 1, between 0 and 2
function Catch:getActionSpec()
  return {'int', 1, {0, 2}}
end

-- Min and max reward
function Catch:getRewardSpec()
  return -1, 1
end

-- Redraws screen based on state
function Catch:redraw()
  -- Reset screen
  self.screen:zero()
  -- Draw ball
  self.screen[{{1}, {self.ball.y}, {self.ball.x}}] = 1
  -- Draw player
  self.screen[{{1}, {self.size}, {self.player.x, self.player.x + self.player.width - 1}}] = 1
end

-- Starts new game
function Catch:start()
  -- Reset player and ball
  self.player.x = math.ceil(self.size / 2)
  self.ball.x = torch.random(self.size)
  self.ball.y = 1
  -- Choose new trajectory
  self.ball.startX = self.ball.x
  self.ball.endX = self.difficulty == 'easy' and self.ball.startX or torch.random(self.size)
  self.ball.gradX = (self.ball.endX - self.ball.startX) / (self.size - 1)

  -- Redraw screen
  self:redraw()

  -- Return observation
  return self.screen
end

-- Steps in a game
function Catch:step(action)
  -- Reward is 0 by default
  local reward = 0

  -- Move player (0 is no-op)
  if action == 1 then
    self.player.x = math.max(self.player.x - 1, 1)
  elseif action == 2 then
    self.player.x = math.min(self.player.x + 1, self.size - self.player.width + 1)
  end

  -- Move ball
  self.ball.x = self.ball.x + self.ball.gradX
  self.ball.y = self.ball.y + 1

  -- Check terminal condition
  local terminal = false
  if self.ball.y == self.size then
    terminal = true
    -- Player wins if it caught ball
    if self.ball.x >= self.player.x and self.ball.x <= self.player.x + self.player.width - 1 then
      reward = 1
    else
      reward = -1
    end
  end
  
  -- Redraw screen
  self:redraw()

  return reward, self.screen, terminal
end

return Catch
