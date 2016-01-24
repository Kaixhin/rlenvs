local rlenvs = {}

-- Include environments
rlenvs.Env = require 'rlenvs/Env'
rlenvs.Atari = require 'rlenvs/Atari'
rlenvs.Blackjack = require 'rlenvs/Blackjack'
rlenvs.Catch = require 'rlenvs/Catch'
rlenvs.CartPole = require 'rlenvs/CartPole'
rlenvs.JacksCarRental = require 'rlenvs/JacksCarRental'
rlenvs.MountainCar = require 'rlenvs/MountainCar'
rlenvs.MultiArmedBandit = require 'rlenvs/MultiArmedBandit'
rlenvs.RandomWalk = require 'rlenvs/RandomWalk'

-- Remove nil environments
for k, v in pairs(rlenvs) do
  if v == true then
    rlenvs[k] = nil
  end
end

return rlenvs
