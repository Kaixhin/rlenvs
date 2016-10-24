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
    if opts.render then
        require 'image' self.qt = pcall(require, 'qt')
        if not self.qt then print('Was not able to load qt to render, are you using qlua to run the script?') end
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
    local obs = self:_start()
    return obs
end

function Env:render()
    if self.qt and self.getDisplay then
        self.window = self.window == nil and image.display({ image = self:getDisplay(), zoom = 10 }) or self.window
        image.display({ image = self:getDisplay(), zoom = 10, win = self.window })
    end
end

return Env
