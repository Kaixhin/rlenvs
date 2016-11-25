require 'torch'
local rlenvs = require 'rlenvs'

local test = torch.TestSuite()
local tester

function test.envs()
    for index, env in ipairs(rlenvs.envs) do
        local function runTest()
            local Env = require('rlenvs.' .. env)
            -- Initialise and start environment
            local env = Env()
            local actionSpace = env:getActionSpace()
            local observation = env:start()
            -- Pick random action and execute it
            local action = torch.random(0, actionSpace['n'] - 1)
            local reward, observation, terminal = env:step(action)
            -- Display if implemented
            env:render()
        end

        if env == 'Atari' then
            local hasALEWrap = pcall(require, 'alewrap')
            if not hasALEWrap then
                tester:assert(pcall(runTest), 'Failed to run rlenv environment ' .. env)
            end
        elseif env == 'Minecraft' then
            local hasSocket = pcall(require, 'socket')
            local hasLibMalmoLua = pcall(require, 'libMalmoLua')
            if not hasSocket and hasLibMalmoLua then
                tester:assert(pcall(runTest), 'Failed to run rlenv environment ' .. env)
            end
        else
            tester:assert(pcall(runTest), 'Failed to run rlenv environment ' .. env)
        end
    end
end

tester = torch.Tester()
tester:add(test)
tester:run()