local rlenvs = {}

-- Include environments
rlenvs.Env = require 'rlenvs/Env'
rlenvs.Atari = require 'rlenvs/Atari'
rlenvs.Catch = require 'rlenvs/Catch'
rlenvs.CartPole = require 'rlenvs/CartPole'
rlenvs.MountainCar = require 'rlenvs/MountainCar'

-- Remove nil environments
for k, v in pairs(rlenvs) do
  if v == true then
    rlenvs[k] = nil
  end
end

return rlenvs
