local classic = require 'classic'

local CliffWalking, super = classic.class('CliffWalking', Env)

-- Constructor
function CliffWalking:_init(opts)
  opts = opts or {}
end

-- 2 states returned, of type 'int', of dimensionality 1, where x is 1-12 and y is 1-4
function CliffWalking:getStateSpec()
  local state = {}
  state['name'] = 'Box'
  state['shape'] = {2}
  state['low'] = {
    1, -- x
    1 -- y
  }
  state['high'] = {
    12, -- x
    4 -- y
  }
  return state
end

-- 1 action required, of type 'int', of dimensionality 1, between 1 and 4 (up|right|down|left)
function CliffWalking:getActionSpec()
  local action = {}
  action['name'] = 'Discrete'
  action['n'] = 4
  return action
end

-- Min and max reward
function CliffWalking:getRewardSpec()
  return -100, -1
end

-- Reset position
function CliffWalking:start()
  self.position = {1, 1}

  return self.position
end

-- Move up, right, down or left
function CliffWalking:step(action)
  action = action + 1 -- scale action
  local reward = -1
  local terminal = false

  -- Move
  if action == 1 then
    -- Move up
    self.position[2] = math.min(self.position[2] + 1, 4)
  elseif action == 2 then
    -- Move right
    self.position[1] = math.min(self.position[1] + 1, 12)
  elseif action == 3 then
    -- Move down
    self.position[2] = math.max(self.position[2] - 1, 1)
  else
    -- Move left
    self.position[1] = math.max(self.position[1] - 1, 1)
  end

  -- Check if fallen off the cliff
  if self.position[2] == 1 then
    if self.position[1] > 1 then
      -- Fallen off cliff or reached goal
      terminal = true
      
      if self.position[1] < 12 then
        reward = -100 -- Fallen
      end
    end
  end

  return reward, self.position, terminal
end

return CliffWalking
