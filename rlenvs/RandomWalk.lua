local classic = require 'classic'

local RandomWalk, super = classic.class('RandomWalk', Env)

-- Constructor
function RandomWalk:_init(opts)
  opts = opts or {}
  super._init(self, opts)
end

-- 1 states returned, of type 'int', of dimensionality 1, between 0 and 6 (the terminal states)
function RandomWalk:getStateSpace()
  local state = {}
  state['name'] = 'Discrete'
  state['n'] = 6
  return state
end

-- 1 action required, of type 'int', of dimensionality 1, between 0 and 1 (left or right)
function RandomWalk:getActionSpace()
  local action = {}
  action['name'] = 'Discrete'
  action['n'] = 2
  return action
end

-- Min and max reward
function RandomWalk:getRewardSpace()
  return 0, 1
end

-- Reset position
function RandomWalk:_start()
  self.position = 3

  return self.position
end

-- Move left or right
function RandomWalk:_step(action)
  local reward = 0
  local terminal = false

  if action == 0 then
    self.position = self.position - 1

    if self.position == 0 then
      terminal = true
    end
  else
    self.position = self.position + 1

    if self.position == 6 then
      reward = 1
      terminal = true
    end
  end

  return reward, self.position, terminal
end

return RandomWalk
