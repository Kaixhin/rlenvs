local classic = require 'classic'

local Env = classic.class('Env')

-- Denote interfaces
Env:mustHave('start')
Env:mustHave('step')
Env:mustHave('stateSpace')
Env:mustHave('actionSpace')
Env:mustHave('rewardSpace')

return Env
