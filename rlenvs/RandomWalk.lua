local classic = require 'classic'

local RandomWalk, super = classic.class('RandomWalk', Env)

-- Constructor
function RandomWalk:_init(opts)
  opts = opts or {}

  -- State
  self.position = 3
end

-- 1 states returned, of type 'int', of dimensionality 1, between 0 and 6 (the terminal states)
function RandomWalk:getStateSpec()
  return {'int', 1, {0, 6}} -- Position
end

-- 1 action required, of type 'int', of dimensionality 1, between 0 and 1 (left or right)
function RandomWalk:getActionSpec()
  return {'int', 1, {0, 1}}
end

-- Min and max reward
function RandomWalk:getRewardSpec()
  return 0, 1
end

-- Reset position
function RandomWalk:start()
  self.position = 3

  return self.position
end

-- Move left or right
function RandomWalk:step(action)
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
