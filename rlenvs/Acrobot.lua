local classic = require 'classic'

local Acrobot, super = classic.class('Acrobot', Env)
Acrobot.timeStepLimit = 500

-- Constructor
function Acrobot:_init(opts)
  opts = opts or {}
  opts.timeStepLimit = Acrobot.timeStepLimit
  super._init(self, opts)

  -- Constants
  self.g = opts.g or 9.8
  self.m1 = opts.m1 or 1 -- Mass of link 1
  self.m2 = opts.m2 or 1 -- Mass of link 2
  self.l1 = opts.l1 or 1 -- Length of link 1
  self.l2 = opts.l2 or 1 -- Length of link 2
  self.lc1 = opts.lc1 or 0.5 -- Length to center of mass of link 1
  self.lc2 = opts.lc2 or 0.5 -- Length to center of mass of link 2
  self.I1 = opts.I1 or 1 -- Moment of inertia of link 1
  self.I2 = opts.I2 or 1 -- Moment of inertia of link 2
  self.tau = opts.tau or 0.05 -- Time step (s)
  self.steps = opts.steps or 4 -- Time steps to take
end

-- 4 states returned, of type 'real', of dimensionality 1, with differing ranges
function Acrobot:getStateSpace()
  local state = {}
  state['name'] = 'Box'
  state['shape'] = {4}
  state['low'] = {
    -math.pi, -- Joint 1 angle
    -math.pi, -- Joint 2 angle
    -4 * math.pi, -- Joint 1 angular velocity
    -9 * math.pi -- Joint 2 angular velocity
  }
  state['high'] = {
    math.pi, -- Joint 1 angle
    math.pi, -- Joint 2 angle
    4 * math.pi, -- Joint 1 angular velocity
    9 * math.pi -- Joint 2 angular velocity
  }
  return state
end

-- 1 action required, of type 'int', of dimensionality 1, with second torque joint in {-1, 0, 1}
function Acrobot:getActionSpace()
  local action = {}
  action['name'] = 'Discrete'
  action['n'] = 3
  return action
end

-- Min and max reward
function Acrobot:getRewardSpace()
  return -1, 0
end

-- Resets the cart
function Acrobot:_start()
  -- Reset angles and velocities
  self.q1 = 0 -- Joint 1 angle
  self.q2 = 0 -- Joint 2 angle
  self.q1Dot = 0 -- Joint 1 angular velocity
  self.q2Dot = 0 -- Joint 2 angular velocity

  return {self.q1, self.q2, self.q1Dot, self.q2Dot}
end

-- Swings the pole via torque on second joint
function Acrobot:_step(action)
  action = action - 1 -- rescale the action
  local reward = -1
  local terminal = false

  for t = 1, self.steps do
    -- Calculate motion of system
    local d1 = self.m1 * math.pow(self.lc1, 2) + self.m2 * (math.pow(self.l1, 2) + math.pow(self.lc2, 2) + 2 * self.l1 * self.lc2 * math.cos(self.q2)) + self.I1 + self.I2
    local d2 = self.m2 * (math.pow(self.lc2, 2) + self.l1 * self.lc2 * math.cos(self.q2)) + self.I2
    local phi2 = self.m2 * self.lc2 * self.g * math.cos(self.q1 + self.q2 - math.pi/2)
    local phi1 = -self.m2 * self.l1 * self.lc2 * math.pow(self.q2Dot, 2) * math.sin(self.q2) - 2 * self.m2 * self.l1 * self.lc2 * self.q2Dot * self.q1Dot * math.sin(self.q2) + (self.m1 * self.lc1 + self.m2 * self.l1) * self.g * math.cos(self.q1 - math.pi / 2) + phi2
    local q2DotDot = (action + d2 / d1 * phi1 - self.m2 * self.l1 * self.lc2 * math.pow(self.q1Dot, 2) * math.sin(self.q2) - phi2) / (self.m2 * math.pow(self.lc2, 2) + self.I2 - math.pow(d2, 2) / d1)
    local q1DotDot = -(d2 / q2DotDot + phi1) / d1

    -- Update state using Euler's method
    self.q1Dot = self.q1Dot + self.tau * q1DotDot
    self.q2Dot = self.q2Dot + self.tau * q2DotDot
    self.q1 = self.q1 + self.tau * self.q1Dot
    self.q2 = self.q2 + self.tau * self.q2Dot
  end

  -- Wrap around angles
  if self.q1 > math.pi then
    self.q1 = -math.pi + (self.q1 % math.pi)
  elseif self.q1 < -math.pi then
    self.q1 = math.pi - (self.q1 % -math.pi)
  end
  if self.q2 > math.pi then
    self.q2 = -math.pi + (self.q2 % math.pi)
  elseif self.q2 < -math.pi then
    self.q2 = math.pi - (self.q2 % -math.pi)
  end
  -- Limit velocities
  self.q1Dot = math.max(self.q1Dot, -4 * math.pi)
  self.q1Dot = math.min(self.q1Dot, 4 * math.pi)
  self.q2Dot = math.max(self.q2Dot, -9 * math.pi)
  self.q2Dot = math.min(self.q2Dot, 9 * math.pi)

  -- Terminate if second joint's height is greater than height of first joint (relative to origin)
  local h = -self.l1 * math.cos(self.q1) - self.l2 * math.sin(math.pi / 2 - self.q1 - self.q2)
  if h > self.l1 then
    reward = 0
    terminal = true
  end

  return reward, {self.q1, self.q2, self.q1Dot, self.q2Dot}, terminal
end

return Acrobot
