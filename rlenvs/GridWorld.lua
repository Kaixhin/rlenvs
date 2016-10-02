local classic = require 'classic'
local image = require 'image'

local GridWorld, super = classic.class('GridWorld', Env)

-- Constructor
function GridWorld:_init(opts)
  opts = opts or {}

  -- Cost of moving in world (discretized)
  self.world = torch.Tensor(101, 101):fill(-0.5)

  -- PuddleWorld
  if opts.puddles then
    -- Create 2D Gaussians to subtract from world
    self.world[{{30, 90}, {30, 50}}]:csub(image.gaussian({width=21, height=61}))
    self.world[{{60, 80}, {1, 50}}]:csub(image.gaussian({width=60, height=21})[{{}, {11, 60}}])
  end
end

-- 2 states returned, of type 'real', of dimensionality 1, from 0-1
function GridWorld:getStateSpace()
  local state = {}
  state['name'] = 'Box'
  state['shape'] = {2}
  state['low'] = {
    0, -- x
    0 -- y
  }
  state['high'] = {
    1, -- x
    1 -- y
  }
  return state
end

-- 1 action required, of type 'int', of dimensionality 1, between 1 and 4
function GridWorld:getActionSpace()
  local action = {}
  action['name'] = 'Discrete'
  action['n'] = 4
  return action
end

-- Min and max reward
function GridWorld:rewardSpace()
  return torch.min(self.world), 0
end

-- Reset position
function GridWorld:start()
  self.position = {0.2, 0.4}

  return self.position
end

-- Move up, right, down or left
function GridWorld:step(action)
  action = action + 1 -- scale action
  local terminal = false

  -- Move
  if action == 1 then
    -- Move up
    self.position[2] = math.min(self.position[2] + 0.05, 1)
  elseif action == 2 then
    -- Move right
    self.position[1] = math.min(self.position[1] + 0.05, 1)
  elseif action == 3 then
    -- Move down
    self.position[2] = math.max(self.position[2] - 0.05, 0)
  else
    -- Move left
    self.position[1] = math.max(self.position[1] - 0.05, 0)
  end

  -- Look up cost of moving to position
  local reward = self.world[{{self.position[1]*100+1}, {self.position[2]*100+1}}][1][1]

  -- Check if reached goal
  if self.position[1] == 1 and self.position[2] == 1 then
    terminal = true
  end

  return reward, self.position, terminal
end

return GridWorld
