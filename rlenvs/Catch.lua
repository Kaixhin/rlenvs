local classic = require 'classic'

local Catch, super = classic.class('Catch', Env)

-- Constructor
function Catch:_init(opts)
  opts = opts or {}

  -- Difficulty level
  self.level = opts.level or 2
  -- Probability of screen flickering
  self.flickering = opts.flickering or 0
  self.flickered = false
  -- Obscured
  self.obscured = opts.obscured or false

  -- Width and height
  self.size = opts.size or 24
  self.screen = torch.Tensor(1, self.size, self.size):zero()
  self.blank = torch.Tensor(1, self.size, self.size):zero()

  -- Player params/state
  self.player = {
    width = opts.playerWidth or math.ceil(self.size / 12)
  }
  -- Ball
  self.ball = {}
end

-- 1 state returned, of type 'int', of dimensionality 1 x self.size x self.size, between 0 and 1
function Catch:getStateSpace()
  local state = {}
  state['name'] = 'Box'
  state['shape'] = {1, self.size, self.size}
  state['low'] = {
    0
  }
  state['high'] = {
    1
  }
  return state
end

-- 1 action required, of type 'int', of dimensionality 1, between 0 and 2
function Catch:getActionSpace()
  local action = {}
  action['name'] = 'Discrete'
  action['n'] = 3
  return action
end

-- RGB screen of size self.size x self.size
function Catch:getDisplaySpec()
  return {'real', {3, self.size, self.size}, {0, 1}}
end

-- Min and max reward
function Catch:getRewardSpace()
  return 0, 1
end

-- Redraws screen based on state
function Catch:redraw()
  -- Reset screen
  self.screen:zero()
  -- Draw ball
  self.screen[{{1}, {self.ball.y}, {self.ball.x}}] = 1
  -- Draw player
  self.screen[{{1}, {self.size}, {self.player.x, self.player.x + self.player.width - 1}}] = 1

  -- Obscure screen?
  if self.obscured then
    local barrier = math.ceil(self.size / 4)
    self.screen[{{1}, {self.size-barrier, self.size-1}, {}}] = 0
  end
end

-- Starts new game
function Catch:start()
  -- Reset player and ball
  self.player.x = math.ceil(self.size / 2)
  self.ball.x = torch.random(self.size)
  self.ball.y = 1
  -- Choose new trajectory
  self.ball.gradX = torch.uniform(-1/3, 1/3)*(1 - self.level)
 
  -- Redraw screen
  self:redraw()

  -- Return observation
  return self.screen
end

-- Steps in a game
function Catch:_step(action)
  -- Reward is 0 by default
  local reward = 0

  -- Move player (0 is no-op)
  if action == 1 then
    self.player.x = math.max(self.player.x - 1, 1)
  elseif action == 2 then
    self.player.x = math.min(self.player.x + 1, self.size - self.player.width + 1)
  end

  -- Move ball
  self.ball.y = self.ball.y + 1
  self.ball.x = self.ball.x + self.ball.gradX
  -- Bounce ball if it hits the side
  if self.ball.x >= self.size then
    self.ball.x = self.size
    self.ball.gradX = -self.ball.gradX
  elseif self.ball.x < 2 and self.ball.gradX < 0 then
    self.ball.x = 5/3
    self.ball.gradX = -self.ball.gradX
  end

  -- Check terminal condition
  local terminal = false
  if self.ball.y == self.size then
    terminal = true
    -- Player wins if it caught ball
    if self.ball.x >= self.player.x and self.ball.x <= self.player.x + self.player.width - 1 then
      reward = 1
    end
  end
  
  -- Redraw screen
  self:redraw()
  
  -- Flickering
  local screen = self.screen
  if math.random() < self.flickering then
    screen = self.blank
    self.flickered = true
  else
    self.flickered = false
  end

  return reward, screen, terminal
end

-- Returns (RGB) display of screen
function Catch:getDisplay()
  if self.flickered then
    return torch.repeatTensor(self.blank, 3, 1, 1)
  else
    return torch.repeatTensor(self.screen, 3, 1, 1)
  end
end

return Catch
