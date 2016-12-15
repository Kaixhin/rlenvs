local classic = require 'classic'

local CartPole, super = classic.class('CartPole', Env)

-- Constructor
function CartPole:_init(opts)
  opts = opts or {}
  
  -- Constants
  self.gravity = opts.gravity or 9.8
  self.cartMass = opts.cartMass or 1.0
  self.poleMass = opts.poleMass or 0.1
  self.poleLength = opts.poleLength or 1.0 -- Original uses 1/2 pole length
  self.forceMagnitude = opts.forceMagnitude or 10.0
  self.tau = opts.tau or 0.02 -- Time step (s)
  -- Derived constants
  self.totalMass = self.cartMass + self.poleMass
  self.poleMassLength = self.poleMass * self.poleLength
end

-- 4 states returned, of type 'real', of dimensionality 1, with differing ranges
function CartPole:getStateSpec()
  return {
    {'real', 1, {-2.4, 2.4}}, -- Cart position
    {'real', 1, {nil, nil}}, -- Cart velocity
    {'real', 1, {math.rad(-12), math.rad(12)}}, -- Pole angle
    {'real', 1, {nil, nil}} -- Pole angular velocity
  }
end

-- 1 action required, of type 'int', of dimensionality 1, between 0 and 1 (left, right)
function CartPole:getActionSpec()
  return {'int', 1, {0, 1}}
end

-- Min and max reward
function CartPole:getRewardSpec()
  return -1, 0
end

-- Resets the cart
function CartPole:start()
  -- Reset position, angle and velocities
  self.x = 0 -- Cart position (m)
  self.xDot = 0 -- Cart velocity
  self.theta = 0 -- Pole angle (rad)
  self.thetaDot = 0 -- Pole angular velocity

  return {self.x, self.xDot, self.theta, self.thetaDot}
end

-- Drives the cart
function CartPole:step(action)
  -- Calculate acceleration
  local force = action == 1 and self.forceMagnitude or -self.forceMagnitude
  local cosTheta = math.cos(self.theta)
  local sinTheta = math.sin(self.theta)
  local temp = (force + 0.5 * self.poleMassLength * math.pow(self.thetaDot, 2) * sinTheta) / self.totalMass
  local thetaDotDot = (self.gravity * sinTheta - cosTheta * temp) / (0.5 * self.poleLength * (4 / 3 - self.poleMass * math.pow(cosTheta, 2) / self.totalMass))
  local xDotDot = temp - 0.5 * self.poleMassLength * thetaDotDot * cosTheta / self.totalMass

  -- Update state using Euler's method
  self.x = self.x + self.tau * self.xDot
  self.xDot = self.xDot + self.tau * xDotDot
  self.theta = self.theta + self.tau * self.thetaDot
  self.thetaDot = self.thetaDot + self.tau * thetaDotDot

  -- Check failure (if cart reaches sides of track/pole tips too much)
  local reward = 1
  local terminal = false
  if self.x < -2.4 or self.x > 2.4 or self.theta < math.rad(-12) or self.theta > math.rad(12) then
    reward = 0
    terminal = true
  end

  return reward, {self.x, self.xDot, self.theta, self.thetaDot}, terminal
end

return CartPole
