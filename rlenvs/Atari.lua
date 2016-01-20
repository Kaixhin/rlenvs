local classic = require 'classic'
-- Do not install if ALEWrap missing
local hasALEWrap, framework = pcall(require, 'alewrap')
if not hasALEWrap then
  return nil
end

local Atari, super = classic.class('Atari', Env)

-- Constructor
function Atari:_init(opts)
  -- Create ALEWrap options from opts
  opts = opts or {}

  local options = {
    game_path = opts.romPath or 'roms',
    env = opts.game,
    actrep = opts.actRep or 1,
    random_starts = opts.randomStarts or 1,
    gpu = opts.gpu and opts.gpu - 1 or -1, -- GPU flag (GPU enables faster screen buffer with CudaTensors)
    pool_frms = { -- Defaults to 2-frame mean-pooling
      type = opts.poolFrmsType or 'mean', -- Max captures periodic events e.g. blinking lasers
      size = opts.poolFrmsSize or 2 -- Pools over frames to prevent problems with fixed interval events as above
    }
  }

  -- Use ALEWrap and Xitari
  self.gameEnv = framework.GameEnvironment(options)
  -- Create mapping from action index to action for game
  self.actions = self.gameEnv:getActions()
  -- Set evaluation mode by default
  self.trainingFlag = false

  -- Screen, reward, terminal flag
  self.screen = nil
  self.reward = nil
  self.terminal = nil
end

-- 1 state returned, of type 'real', of dimensionality 3 x 210 x 160, between 0 and 1
function Atari:getStateSpec()
  return {'real', {3, 210, 160}, {0, 1}}
end

-- 1 action required, of type 'int', of dimensionality 1, between 1 and 18 (max)
function Atari:getActionSpec()
  return {'int', 1, {1, #self.actions}}
end

-- Min and max reward (unknown)
function Atari:getRewardSpec()
  return nil, nil
end

-- Starts a new game, possibly with a random number of no-ops
function Atari:start()
  if self.gameEnv._random_starts > 0 then
    return self.gameEnv:nextRandomGame()
  else
    return self.gameEnv:newGame()
  end
end

-- Steps in a game
function Atari:step(action)
  -- Map action index to action for game
  action = self.actions[action]

  -- Step in the game
  self.screen, self.reward, self.terminal = self.gameEnv:step(action, self.trainingFlag)

  return self.reward, self.screen, self.terminal
end

-- Set training mode (losing a life triggers terminal signal)
function Atari:training()
  self.trainingFlag = true
end

-- Set evaluation mode (losing lives does not necessarily end an episode)
function Atari:evaluate()
  self.trainingFlag = false
end

return Atari
