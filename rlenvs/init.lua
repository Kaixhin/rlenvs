local rlenvs = {}

-- Include environments
rlenvs.Env = require 'rlenvs/Env'
rlenvs.Atari = require 'rlenvs/Atari'
rlenvs.Catch = require 'rlenvs/Catch'
rlenvs.MountainCar = require 'rlenvs/MountainCar'

return rlenvs
