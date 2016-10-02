local image = require 'image'
local Catch = require 'rlenvs/Catch'

-- Detect QT for image display
local qt = pcall(require, 'qt')

-- Initialise and start environment
local env = Catch({level = 2})
local actionSpace = env:actionSpace()
local observation = env:start()

local reward, terminal = 0, false
local episodes, totalReward = 0, 0
local nEpisodes = 1000

-- Display
local window = qt and image.display({image=observation, zoom=10})

for i = 1, nEpisodes do
  while not terminal do
    -- Pick random action and execute it
    local action = torch.random(0, actionSpace['n'] - 1)
    reward, observation, terminal = env:step(action)
    totalReward = totalReward + reward

    -- Display
    if qt then
        image.display({image=observation, zoom=10, win=window})
    end
  end

  episodes = episodes + 1
  observation = env:start()
  terminal = false
end
print('Episodes: ' .. episodes)
print('Total Reward: ' .. totalReward)
