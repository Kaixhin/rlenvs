local classic = require 'classic'

-- Blackjack with stand, hit, and usable ace specified
local Blackjack, super = classic.class('Blackjack', Env)

-- Constructor
function Blackjack:_init(opts)
  opts = opts or {}

  -- Create number-only suit
  self.suit = torch.Tensor({2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10, 11})
end

-- 2 states returned, of type 'int', of dimensionality 1, for the player sum, dealer's showing card, and player-usable ace
function Blackjack:getStateSpec()
  return {
    {'int', 1, {2, 20}},
    {'int', 1, {1, 10}},
    {'int', 1, {0, 1}}
  }
end

-- 1 action required, of type 'int', of dimensionality 1, either stand or hit
function Blackjack:getActionSpec()
  return {'int', 1, {0, 1}}
end

-- Min and max reward
function Blackjack:getRewardSpec()
  return -1, 1
end

-- Draw 2 cards for player and dealer
function Blackjack:start()
  -- Shuffle deck
  self.deck = torch.cat({self.suit, self.suit, self.suit, self.suit}, 1):index(1, torch.randperm(52):long())

  -- Player state
  self.playerSum = self.deck[1] + self.deck[3]
  self.usableAce = (self.deck[1] == 11 or self.deck[3] == 11) and 1 or 0
  if self.playerSum > 21 then
    self.playerSum = self.playerSum - 10
    self.usableAce = 1
  end

  -- Dealer state
  self.dealerCard = self.deck[2]
  self.draw = 5  -- Index to draw card from (reserves 4th card for dealer)

  return {self.playerSum, self.dealerCard, self.usableAce}
end

-- Player stands or hits
function Blackjack:step(action)
  local reward = 0
  local terminal = false

  if action == 1 then
    -- Player hits
    self.playerSum = self.playerSum + self.deck[self.draw]
    self.draw = self.draw + 1

    -- Check if player is bust
    if self.playerSum > 21 then
      -- Check for usable ace
      if self.usableAce == 1 then
        self.playerSum = self.playerSum - 10
        self.usableAce = self.deck[self.draw - 1] == 11 and 1 or 0
      else
        reward = -1
        terminal = true
      end
    end
  else
    -- Player is finished
    terminal = true
    
    -- Dealer's second card actually drawn now
    local dealerSum = self.dealerCard + self.deck[4]
    local dealerAce = (self.dealerCard == 11 or self.deck[4] == 11) and 1 or 0
    if dealerSum > 21 then
      -- Only occurs if 2 aces drawn
      dealerSum = dealerSum - 10
      dealerAce = 1
    end
    
    -- Dealer draws until they reach at least 17
    while dealerSum < 17 do
      dealerSum = dealerSum + self.deck[self.draw]
      self.draw = self.draw + 1

      -- Check for usable ace
      if dealerSum >= 17 and dealerAce == 1 then
        dealerSum = dealerSum - 10
        dealerAce = self.deck[self.draw - 1] == 11 and 1 or 0
      end
    end

    -- Check for player win
    if self.playerSum > dealerSum or dealerSum > 21 then
      reward = 1
    elseif dealerSum > self.playerSum then
      reward = -1
    end
  end

  return reward, {self.playerSum, self.dealerCard, self.usableAce}, terminal
end

return Blackjack
