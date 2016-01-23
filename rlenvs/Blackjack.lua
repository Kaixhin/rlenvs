local classic = require 'classic'

-- Blackjack with stick, hit, and no usable ace (ace = 1)
local Blackjack, super = classic.class('Blackjack', Env)

-- Constructor
function Blackjack:_init(opts)
  opts = opts or {}

  -- State
  self.playerSum = torch.random(2, 20)
  self.dealerCard = torch.random(1, 10)
end

-- 2 states returned, of type 'int', of dimensionality 1, for the player sum and dealer's showing card
function Blackjack:getStateSpec()
  return {
    {'int', 1, {2, 20}},
    {'int', 1, {1, 10}}
  }
end

-- 1 action required, of type 'int', of dimensionality 1, either stick or hit
function Blackjack:getActionSpec()
  return {'int', 1, {0, 1}}
end

-- Min and max reward
function Blackjack:getRewardSpec()
  return -1, 1
end

-- Draw 2 cards for player and dealer
function Blackjack:start()
  self.playerSum = torch.random(2, 20)
  self.dealerCard = torch.random(1, 10) -- Only one dealer card shown, so second card is actually drawn when player sticks

  return {self.playerSum, self.dealerCard}
end

-- Player sticks or hits
function Blackjack:step(action)
  local reward = 0
  local terminal = false

  if action == 1 then
    -- Player hits
    self.playerSum = self.playerSum + torch.random(1, 10)

    -- Check if player is bust
    if self.playerSum > 21 then
      reward = -1
      terminal = true
    end
  else
    -- Player is finished
    terminal = true
    
    -- Dealer's second card actually drawn now
    local dealerSum = self.dealerCard + torch.random(1, 10)
    
    -- Dealer draws until they reach at least 17
    while dealerSum < 17 do
      dealerSum = dealerSum + torch.random(1, 10)
    end

    -- Check for player win
    if self.playerSum > dealerSum or dealerSum > 21 then
      reward = 1
    elseif dealerSum > self.playerSum then
      reward = -1
    end
  end

  return reward, {self.playerSum, self.dealerCard}, terminal
end

return Blackjack
