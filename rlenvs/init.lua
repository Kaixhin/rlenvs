local rlenvs = {}

-- Include environments
rlenvs.Env = require 'rlenvs/Env'
rlenvs.Atari = require 'rlenvs/Atari'
rlenvs.Catch = require 'rlenvs/Catch'
rlenvs.CartPole = require 'rlenvs/CartPole'
rlenvs.MountainCar = require 'rlenvs/MountainCar'
rlenvs.NArmedBandit = require 'rlenvs/NArmedBandit'

return rlenvs
