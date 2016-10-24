local classic = require 'classic'

local Env = classic.class('Env')

-- Denote interfaces
Env:mustHave('_start')
Env:mustHave('_step')
Env:mustHave('getStateSpace')
Env:mustHave('getActionSpace')
Env:mustHave('getRewardSpace')

function Env:_init(opts)
    if opts.timeStepLimit and opts.maxSteps then
        self.maxSteps = math.min(opts.timeStepLimit, opts.maxSteps)
    elseif opts.maxSteps then
        self.maxSteps = opts.maxSteps
    elseif opts.timeStepLimit then
        self.maxSteps = opts.timeStepLimit
    else
        self.maxSteps = 1000
    end
    self.currentStep = 1
end

function Env:step(action)
    local reward, state, terminal = self:_step(action)
    if self.currentStep == self.maxSteps then
        terminal = true
        self.currentStep = 0
    end
    self.currentStep = self.currentStep + 1
    return reward, state, terminal
end

function Env:start()
    self.currentStep = 1
    return self:_start()
end

return Env
