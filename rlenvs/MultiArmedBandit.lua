local classic = require 'classic'

local MultiArmedBandit, super = classic.class('MultiArmedBandit', Env)

-- Constructor
function MultiArmedBandit:_init(opts)
  opts = opts or {}

  -- Restless bandits (with a Gaussian random walk)
  self.restless = opts.restless or false

  -- Number of plays allowed
  self.plays = 1
  self.maxPlays = opts.maxPlays or 1000
  -- Arms
  self.nArms = opts.nArms or 10
  -- Set up probability distributions
  self.armMeans = torch.Tensor(self.nArms):normal(0, 1)
end

-- No state (not a contextual bandit)
function MultiArmedBandit:getStateSpec()
  return nil
end

-- 1 action required, of type 'int', of dimensionality 1, of the number of arms
function MultiArmedBandit:getActionSpec()
  return {'int', 1, {1, self.nArms}}
end

-- Min and max rewards unknown when sampling from distributions
function MultiArmedBandit:getRewardSpec()
  return nil, nil
end

-- Does nothing (distributions do not reset)
function MultiArmedBandit:start()
  return nil
end

-- Pulls an arm
function MultiArmedBandit:step(action)
  -- Sample for reward
  local reward = torch.normal(self.armMeans[action], 1)

  -- Change reward distribution if restless
  if self.restless then
    self.armMeans:add(torch.Tensor(self.nArms):normal(0, 0.1))
  end

  -- Terminate after self.maxPlays
  self.plays = self.plays + 1
  local terminal = self.plays == self.maxPlays and true or false

  return reward, nil, terminal
end

return MultiArmedBandit
