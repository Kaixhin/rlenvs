local classic = require 'classic'

local JacksCarRental, super = classic.class('JacksCarRental', Env)

-- Generate Poisson samples (Knuth's algorithm)
local poisson = function(lambda)
  local L = math.exp(-lambda)
  local k = 0
  local p = 1

  while p > L do
    k = k + 1
    p = p * torch.uniform()
  end
  
  return k - 1
end

-- Constructor
function JacksCarRental:_init(opts)
  opts = opts or {}
end

-- 2 states returned, of type 'int', of dimensionality 1, for 0-20 cars
function JacksCarRental:stateSpace()
  local state = {}
  state['name'] = 'Box'
  state['shape'] = {2}
  state['low'] = {
    0, -- Lot 1
    0 -- Lot 2
  }
  state['high'] = {
    20, -- Lot 1
    20 -- Lot 2
  }
  return state
end

-- 1 action required, of type 'int', of dimensionality 1, between -5 and 5 (max 5 cars can be moved overnight)
function JacksCarRental:actionSpace()
  local action = {}
  action['name'] = 'Discrete'
  action['n'] = 10
  return action
end

-- Min and max reward
function JacksCarRental:rewardSpace()
  return 0, 200
end

-- Resets the cars to 10 at each lot
function JacksCarRental:start()
  self.lot1 = 10
  self.lot2 = 10

  return {self.lot1, self.lot2}
end

-- Acts out a day and night for Jack's Car Rental
function JacksCarRental:step(action)
  action = action - 5 -- scale action
  local reward = 0 -- Reward in $

  -- Customers rent cars from lot 1 during the day
  local lot1Rentals = math.min(poisson(3), self.lot1)
  self.lot1 = self.lot1 - lot1Rentals
  reward = reward + 10*lot1Rentals

  -- Customers rent cars from lot 2 during the day
  local lot2Rentals = math.min(poisson(4), self.lot2)
  self.lot2 = self.lot2 - lot2Rentals
  reward = reward + 10*lot2Rentals

  -- Customers return cars to lot 1 at the end of the day
  local lot1Returns = poisson(3)
  self.lot1 = math.min(self.lot1 + lot1Returns, 20)

  -- Customers return cars to lot 2 at the end of the day
  local lot2Returns = poisson(2)
  self.lot2 = math.min(self.lot2 + lot2Returns, 20)

  -- Jack chooses how many cars to move overnight (max 5)
  local carsMoved
  if action > 0 then
    carsMoved = math.min(action, self.lot1) -- Cannot move more cars than are available
    carsMoved = math.min(carsMoved, 20 - self.lot2) -- Cannot keep more than 20 cars in a lot
    -- Move cars
    self.lot1 = self.lot1 - carsMoved
    self.lot2 = self.lot2 + carsMoved
    reward = reward - 2*carsMoved
  elseif action < 0 then -- Negative numbers indicate transferring cars from lot 2 to lot 1
    carsMoved = math.min(-action, self.lot2)
    carsMoved = math.min(carsMoved, 20 - self.lot1)
    -- Move cars
    self.lot2 = self.lot2 - carsMoved
    self.lot1 = self.lot1 + carsMoved
    reward = reward - 2*carsMoved
  end

  return reward, {self.lot1, self.lot2}, false
end

return JacksCarRental
