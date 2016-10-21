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
  if opts.lifeLossTerminal == nil then
    opts.lifeLossTerminal = true
  end

  local options = {
    game_path = opts.romPath or 'roms',
    env = opts.game,
    actrep = opts.actRep or 4,
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

  -- Full actions mode
  if opts.fullActions then
    self.actions = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17}
  end
  
  -- Life loss = terminal mode
  self.lifeLossTerminal = opts.lifeLossTerminal
end

-- 1 state returned, of type 'real', of dimensionality 3 x 210 x 160, between 0 and 1
function Atari:getStateSpace()
  local state = {}
  state['name'] = 'Box'
  state['shape'] = {3, 210, 160}
  state['low'] = {
    0
  }
  state['high'] = {
    1
  }
  return state
end

-- 1 action required, of type 'int', of dimensionality 1, between 1 and 18 (max)
function Atari:getActionSpace()
  local action = {}
  action['name'] = 'Discrete'
  action['n'] = #self.actions
  return action
end

-- RGB screen of height 210 and width 160
function Atari:getDisplaySpec()
  return {'real', {3, 210, 160}, {0, 1}}
end

-- Min and max reward (unknown)
function Atari:getRewardSpace()
  return nil, nil
end

-- Starts a new game, possibly with a random number of no-ops
function Atari:start()
  local screen, reward, terminal
  
  if self.gameEnv._random_starts > 0 then
    screen, reward, terminal = self.gameEnv:nextRandomGame()
  else
    screen, reward, terminal = self.gameEnv:newGame()
  end

  return screen:select(1, 1)
end

-- Steps in a game
function Atari:_step(action)
  -- Map action index to action for game
  action = self.actions[action]

  -- Step in the game
  local screen, reward, terminal = self.gameEnv:step(action, self.trainingFlag)

  return reward, screen:select(1, 1), terminal
end

-- Returns display of screen
function Atari:getDisplay()
  return self.gameEnv._state.observation:select(1, 1)
end

-- Set training mode (losing a life triggers terminal signal)
function Atari:training()
  if self.lifeLossTerminal then
    self.trainingFlag = true
  end
end

-- Set evaluation mode (losing lives does not necessarily end an episode)
function Atari:evaluate()
  self.trainingFlag = false
end

return Atari
