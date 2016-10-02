local classic = require 'classic'

local Env = classic.class('Env')

-- Denote interfaces
Env:mustHave('start')
Env:mustHave('step')
Env:mustHave('getStateSpace')
Env:mustHave('getActionSpace')
Env:mustHave('rewardSpace')

return Env
