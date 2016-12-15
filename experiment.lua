local Catch = require 'rlenvs.Catch'

-- Initialise and start environment
local env = Catch({level = 2, render = true, zoom = 10})
local actionSpace = env:getActionSpace()
local observation = env:start()

local reward, terminal = 0, false
local episodes, totalReward = 0, 0
local nEpisodes = 1000

-- Display
env:render()

for i = 1, nEpisodes do
  while not terminal do
    -- Pick random action and execute it
    local action = torch.random(0, actionSpace['n'] - 1)
    reward, observation, terminal = env:step(action)
    totalReward = totalReward + reward

    -- Display
    env:render()
  end

  episodes = episodes + 1
  observation = env:start()
  terminal = false
end
print('Episodes: ' .. episodes)
print('Total Reward: ' .. totalReward)
