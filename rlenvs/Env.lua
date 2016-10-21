local classic = require 'classic'

local Env = classic.class('Env')

-- Denote interfaces
Env:mustHave('start')
Env:mustHave('_step')
Env:mustHave('getStateSpace')
Env:mustHave('getActionSpace')
Env:mustHave('getRewardSpace')

function Env:step(action)
    local reward, state, terminal = self:_step(action)
    self.currentStep = self.currentStep == nil and 1 or self.currentStep
    self.maxSteps = self.maxSteps == nil and 1000 or self.maxSteps
    if self.currentStep == self.maxSteps then
        terminal = true
        self.currentStep = 0
    end
    self.currentStep = self.currentStep + 1
    return reward, state, terminal
end

return Env
