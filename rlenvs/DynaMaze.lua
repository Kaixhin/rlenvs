local classic = require 'classic'

local DynaMaze, super = classic.class('DynaMaze', Env)

-- Constructor
function DynaMaze:_init(opts)
  opts = opts or {}

  -- Set change: none|blocking|shortcut
  self.change = opts.change or 'none'

  -- Create blank grid (y, x)
  self.maze = torch.ByteTensor(6, 9):zero()
  -- Place blocks
  if self.change == 'none' then
    self.maze[{{3, 5}, {3}}] = 1
    self.maze[{{2}, {6}}] = 1
    self.maze[{{4, 6}, {8}}] = 1
  elseif self.change == 'blocking' then
    self.maze[{{3}, {1, 8}}] = 1
  elseif self.change == 'shortcut' then
    self.maze[{{3}, {2, 9}}] = 1
  end

  -- Keep internal step counter
  self.counter = 0
end

-- 2 states returned, of type 'int', of dimensionality 1, where x is 1-9 and y is 1-6
function DynaMaze:getStateSpace()
  local state = {}
  state['name'] = 'Box'
  state['shape'] = {2}
  state['low'] = {
    1, -- x
    1 -- y
  }
  state['high'] = {
    9, -- x
    6 -- y
  }
  return state
end

-- 1 action required, of type 'int', of dimensionality 1, between 1 and 4
function DynaMaze:getActionSpace()
  local action = {}
  action['name'] = 'Discrete'
  action['n'] = 4
  return action
end

-- Min and max reward
function DynaMaze:getRewardSpace()
  return 0, 1
end

-- Reset position
function DynaMaze:start()
  if self.change == 'none' then
    self.position = {1, 4}
  else
    self.position = {4, 1}
  end

  return self.position
end

-- Move up, right, down or left
function DynaMaze:_step(action)
  action = action + 1 -- scale action
  local reward = 0
  local terminal = false

  -- Calculate new position
  local newX = self.position[1]
  local newY = self.position[2]
  if action == 1 then
    -- Move up
    newY = math.min(newY + 1, 6)
  elseif action == 2 then
    -- Move right
    newX = math.min(newX + 1, 9)
  elseif action == 3 then
    -- Move down
    newY = math.max(newY - 1, 1)
  else
    -- Move left
    newX = math.max(newX - 1, 1)
  end

  -- Move if not blocked
  if self.maze[{{newY}, {newX}}][1][1] == 0 then
    self.position[1] = newX
    self.position[2] = newY
  end

  -- Check if reached goal
  if newX == 9 and newY == 6 then
    reward = 1
    terminal = true
  end

  -- Increment counter
  self.counter = self.counter + 1
  -- Change environment
  if self.counter == 1000 and self.change == 'blocking' then
    -- Open up hole in left of wall
    self.maze[{{3}, {1}}] = 0
    -- Fill up hole on right of wall
    self.maze[{{3}, {9}}] = 1
    -- Move agent in case it is now on top of wall
    if self.position[1] == 9 and self.position[2] == 3 then
      self.position[1] = 4
    end
  elseif self.counter == 3000 and self.change == 'shortcut' then
    -- Open up hole in wall
    self.maze[{{3}, {9}}] = 0
  end

  return reward, self.position, terminal
end

return DynaMaze
