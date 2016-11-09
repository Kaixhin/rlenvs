local classic = require 'classic'

local WindyWorld, super = classic.class('WindyWorld', Env)

-- Constructor
function WindyWorld:_init(opts)
  opts = opts or {}

  -- Allow king's moves (8 directions)
  self.king = opts.king or false
end

-- 2 states returned, of type 'int', of dimensionality 1, where x is 1-10 and y is 1-7
function WindyWorld:getStateSpace()
  local state = {}
  state['name'] = 'Box'
  state['shape'] = {5}
  state['low'] = {
    1, -- x
    1 -- y
  }
  state['high'] = {
    10, -- x
    7 -- y
  }
  return state
end

-- 1 action required, of type 'int', of dimensionality 1, between 1 and 4 (for standard) or 1 and 8 (for king)
function WindyWorld:getActionSpace()
  local action = {}
  action['name'] = 'Discrete'
  if self.king then
    action['n'] = 8
    return action
  else
    action['n'] = 4
    return action
  end
end

-- Min and max reward
function WindyWorld:getRewardSpace()
  return -1, -1
end

-- Reset position
function WindyWorld:start()
  self.position = {1, 4}

  return self.position
end

-- Move up, right, down or left
function WindyWorld:_step(action)
  action = action + 1 -- scale action
  local terminal = false

  -- Move
  if action == 1 then
    -- Move up
    self.position[2] = math.min(self.position[2] + 1, 7)
  elseif action == 2 then
    -- Move right
    self.position[1] = math.min(self.position[1] + 1, 10)
  elseif action == 3 then
    -- Move down
    self.position[2] = math.max(self.position[2] - 1, 1)
  elseif action == 4 then
    -- Move left
    self.position[1] = math.max(self.position[1] - 1, 1)
  elseif action == 5 then
      -- Move up-right
    self.position[2] = math.min(self.position[2] + 1, 7)
    self.position[1] = math.min(self.position[1] + 1, 10)
  elseif action == 6 then
    -- Move down-right
    self.position[2] = math.max(self.position[2] - 1, 1)
    self.position[1] = math.min(self.position[1] + 1, 10)
  elseif action == 7 then
    -- Move down-left
    self.position[2] = math.max(self.position[2] - 1, 1)
    self.position[1] = math.max(self.position[1] - 1, 1)
  else
    -- Move up-left
    self.position[2] = math.min(self.position[2] + 1, 7)
    self.position[1] = math.max(self.position[1] - 1, 1)
  end

  -- Apply wind
  if self.position[1] >=4 and self.position[1] <= 9 then
    self.position[2] = math.min(self.position[2] + 1, 7)
  end
  if self.position[1] == 7 or self.position[1] == 8 then
    self.position[2] = math.min(self.position[2] + 1, 7)
  end

  -- Check if reached goal
  if self.position[1] == 8 and self.position[2] == 4 then
    terminal = true
  end

  return -1, self.position, terminal
end

return WindyWorld
