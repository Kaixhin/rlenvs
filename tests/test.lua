local rlenvs = require 'rlenvs'

local function runTest(env)
    local Env = require('rlenvs.' .. env)
    -- Initialise and start environment
    local env = Env()
    local actionSpace = env:getActionSpace()
    local observation = env:start()
    -- Pick random action and execute it
    local action = torch.random(0, actionSpace['n'] - 1)
    local reward, observation, terminal = env:step(action)
    -- Display
    env:render()
end


for index, env in ipairs(rlenvs.envs) do
    if env ~= 'Atari' then
        runTest(env)
    end
end