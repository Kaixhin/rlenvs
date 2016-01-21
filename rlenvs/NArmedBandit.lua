local classic = require 'classic'

local NArmedBandit, super = classic.class('NArmedBandit', Env)

-- Constructor
function NArmedBandit:_init(opts)
  opts = opts or {}

  -- Number of plays allowed
  self.plays = 1
  self.maxPlays = opts.maxPlays or 1000
  -- Arms
  self.nArms = opts.nArms or 10
  -- Set up probability distributions
  self.armMeans = torch.Tensor(self.nArms):normal(0, 1)
end

-- No state (not a contextual bandit)
function NArmedBandit:getStateSpec()
  return nil
end

-- 1 action required, of type 'int', of dimensionality 1, of the number of arms
function NArmedBandit:getActionSpec()
  return {'int', 1, {1, self.nArms}}
end

-- Min and max rewards unknown when sampling from distributions
function NArmedBandit:getRewardSpec()
  return nil, nil
end

-- Does nothing (distributions do not reset)
function NArmedBandit:start()
  return nil
end

-- Pulls an arm
function NArmedBandit:step(action)
  -- Sample for reward
  local reward = torch.normal(self.armMeans[action], 1)

  -- Terminate after self.maxPlays
  self.plays = self.plays + 1
  local terminal = self.plays == self.maxPlays and true or false

  return reward, nil, terminal
end

return NArmedBandit
