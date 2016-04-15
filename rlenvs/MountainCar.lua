local classic = require 'classic'

local MountainCar, super = classic.class('MountainCar', Env)

-- Constructor
function MountainCar:_init(opts)
  opts = opts or {}
end

-- 2 states returned, of type 'real', of dimensionality 1, with differing ranges
function MountainCar:getStateSpec()
  return {
    {'real', 1, {-0.07, 0.07}}, -- Velocity
    {'real', 1, {-1.2, 0.6}} -- Position
  }
end

-- 1 action required, of type 'int', of dimensionality 1, between -1 and 1 (left, neutral, right)
function MountainCar:getActionSpec()
  return {'int', 1, {-1, 1}}
end

-- Min and max reward
function MountainCar:getRewardSpec()
  return -2, 0 -- As height = sin(3x) is between -1 and 1, and reward = height - 1
end

-- Resets the car
function MountainCar:start()
  -- Reset position and velocity
  self.position = -0.5
  self.velocity = 0

  return {self.velocity, self.position}
end

-- Drives the car
function MountainCar:step(action)
  -- Calculate height
  local height = math.sin(3*self.position)

  -- Update velocity and position
  self.velocity = self.velocity + 0.001*action - 0.0025*math.cos(3*self.position)
  self.velocity = math.max(self.velocity, -0.07)
  self.velocity = math.min(self.velocity, 0.07)
  self.position = self.position + self.velocity
  self.position = math.max(self.position, -1.2)
  self.position = math.min(self.position, 0.6)
  -- Reset velocity if at very left
  if self.position == -1.2 and self.velocity < 0 then
    self.velocity = 0
  end

  -- Calculate reward
  local reward = height - 1
  -- Calculate termination
  local terminal = self.position >= 0.5 -- Car has made it over the (right) hill

  return reward, {self.velocity, self.position}, terminal
end

return MountainCar
