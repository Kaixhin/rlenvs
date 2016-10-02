local classic = require 'classic'

--[[
-- MAP
--    _________
-- 4 |R  |    G|
-- 3 |   |     |
-- 2 |         |
-- 1 | |  F|   |
-- 0 |Y|___|B__|
--    0 1 2 3 4
--]]

local Taxi, super = classic.class('Taxi', Env)

-- Constructor
function Taxi:_init(opts)
  opts = opts or {}

  -- Passenger positions (Red, Green, Blue, Yellow)
  self.rgbyPos = {{0, 4}, {4, 4}, {3, 0}, {0, 0}}
  -- Refuelling position
  self.fuelPos = {2, 1}
end

-- 4 states returned, of type 'int', of dimensionality 1, where x and y are 0-5, fuel is -1-12, passenger position is 1-5 and destination is 1-4
function Taxi:stateSpace()
  local state = {}
  state['name'] = 'Box'
  state['shape'] = {5}
  state['low'] = {
    0, -- x
    0, -- y
    -1, -- Fuel
    1, -- Passenger location
    1 -- Destination TODO: Work out why there are apparently 5 destination states in the original paper
  }
  state['high'] = {
    4, -- x
    4, -- y
    12, -- Fuel
    5, -- Passenger location
    4 -- Destination
  }
  return state
end

-- 1 action required, of type 'int', of dimensionality 1, where 1-4 is move N, E, S, W, 5 is Pickup, 6 is Putdown and 7 is Fillup
function Taxi:actionSpace()
  local action = {}
  action['name'] = 'Discrete'
  action['n'] = 7
  return action
end

-- Min and max reward
function Taxi:rewardSpace()
  return -20, 20
end

-- Reset position, fuel and passenger
function Taxi:start()
  -- Randomise position and fuel
  self.position = {torch.random(0, 4), torch.random(0, 4)}
  self.fuel = torch.random(5, 12)

  -- Random passenger position (R, G, B, Y)
  self.passenger = torch.random(1, 4)
  -- Randomise source and destination
  self.source = self.rgbyPos[self.passenger]
  self.destNode = torch.random(1, 4)
  self.destination = self.rgbyPos[self.destNode] -- Can be same as source

  return {self.position[1], self.position[2], self.fuel, self.passenger, self.destNode}
end

-- Checks validity of moves (i.e. checks wall collisions)
function Taxi:validMove(action)
  local x, y = self.position[1], self.position[2]

  if action == 1 then
    -- Cannot move North
    if y == 4 then
      return false
    end
  elseif action == 2 then
    -- Cannot move East
    if x == 4 or (x == 0 and (y == 0 or y == 1)) or (x == 1 and (y == 3 or y == 4)) or (x == 2 and (y == 0 or y == 1)) then
      return false
    end
  elseif action == 3 then
    -- Cannot move South
    if y == 0 then
      return false
    end
  elseif action == 4 then
    -- Cannot move West
    if x == 0 or (x == 1 and (y == 0 or y == 1)) or (x == 2 and (y == 3 or y == 4)) or (x == 3 and (y == 0 or y == 1)) then
      return false
    end
  end

  return true
end

-- Move up, right, down or left
function Taxi:step(action)
  local reward = -1
  local terminal = false

  -- Perform action
  if action == 1 then
    -- Move North
    if self:validMove(action) then
      self.position[2] = self.position[2] + 1
      self.fuel = self.fuel - 1
    end
  elseif action == 2 then
    -- Move East
    if self:validMove(action) then
      self.position[1] = self.position[1] + 1
      self.fuel = self.fuel - 1
    end
  elseif action == 3 then
    -- Move South
    if self:validMove(action) then
      self.position[2] = self.position[2] - 1
      self.fuel = self.fuel - 1
    end
  elseif action == 4 then
    -- Move West
    if self:validMove(action) then
      self.position[1] = self.position[1] - 1
      self.fuel = self.fuel - 1
    end
  elseif action == 5 then
    -- Pickup
    if self.passenger ~= 5 and self.position[1] == self.source[1] and self.position[2] == self.source[2] then
      -- Pick up passenger
      self.passenger = 5
    else
      -- Penalise for illegal action
      reward = -10
    end
  elseif action == 6 then
    -- Putdown
    if self.passenger == 5 and self.position[1] == self.destination[1] and self.position[2] == self.destination[2] then
      -- Finish successfully
      reward = 20
      terminal = true
    else
      -- Penalise for illegal action
      reward = -10
    end
  else
    -- Fillup
    if self.position[1] == self.fuelPos[1] and self.position[2] == self.fuelPos[2] then
      -- Refuel only if at refuelling location
      self.fuel = 12
    end
  end

  -- Check fuel (can have 0 fuel and still succeed if at destination)
  if self.fuel < 0 then
    reward = -20
    terminal = true
  end

  return reward, {self.position[1], self.position[2], self.fuel, self.passenger, self.destNode}, terminal
end

return Taxi
