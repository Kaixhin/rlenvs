local rlenvs = {}

-- Include environments
torch.include(rlenvs, 'Env.lua')
torch.include(rlenvs, 'Catch.lua')

return rlenvs
