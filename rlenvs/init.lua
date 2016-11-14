local rlenvs = {}

-- Include environments
rlenvs.Env = require 'rlenvs/Env'
rlenvs.Acrobot = require 'rlenvs/Acrobot'
rlenvs.Atari = require 'rlenvs/Atari'
rlenvs.Blackjack = require 'rlenvs/Blackjack'
rlenvs.CartPole = require 'rlenvs/CartPole'
rlenvs.Catch = require 'rlenvs/Catch'
rlenvs.CliffWalking = require 'rlenvs/CliffWalking'
rlenvs.DynaMaze = require 'rlenvs/DynaMaze'
rlenvs.GridWorld = require 'rlenvs/GridWorld'
rlenvs.JacksCarRental = require 'rlenvs/JacksCarRental'
rlenvs.Minecraft = require 'rlenvs/Minecraft'
rlenvs.MountainCar = require 'rlenvs/MountainCar'
rlenvs.MultiArmedBandit = require 'rlenvs/MultiArmedBandit'
rlenvs.RandomWalk = require 'rlenvs/RandomWalk'
rlenvs.Taxi = require 'rlenvs/Taxi'
rlenvs.WindyWorld = require 'rlenvs/WindyWorld'

-- Remove nil environments
for k, v in pairs(rlenvs) do
  if v == true then
    rlenvs[k] = nil
  end
end

return rlenvs
