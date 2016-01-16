local rlenvs = {}

-- Include environments
torch.include(rlenvs, 'Env.lua')
torch.include(rlenvs, 'Catch.lua')
torch.include(rlenvs, 'MountainCar.lua')
torch.include(rlenvs, 'Atari.lua')

return rlenvs
