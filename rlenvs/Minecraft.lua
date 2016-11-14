local hasSocket, socket = pcall(require, 'socket')
if not hasSocket then
  print("Requires luasocket (luarocks install luasocket)")
  os.exit()
end
local hasLibMalmoLua, libMalmoLua = pcall(require, 'libMalmoLua')
if not hasLibMalmoLua then
  print("Requires libMalmoLua.so in the same folder")
  os.exit()
end
local classic = require 'classic'
local image = require 'image'

local Minecraft, super = classic.class('Minecraft', Env)

local function sleep(sec)
  socket.select(nil, nil, sec)
end

-- Constructor
function Minecraft:_init(opts)
  self.opts = opts or {}

  self.height = opts.height or 84
  self.width = opts.width or 84
  self.histLen = opts.histLen or 1
  self.mission_xml = opts.mission_xml or "basic.xml"
  self.time_limit = opts.time_limit or 10
  self.actions = opts.actions or {"move 1", "move -1", "turn 1", "turn -1"}

  self.agent_host = AgentHost()

  if self.histLen > 1 then
    self.agent_host:setVideoPolicy("1")
  end

  print("Loading mission XML from: " .. self.mission_xml)
  local f = assert(io.open(self.mission_xml, "r"), "Error loading mission")
  self.mission_xml = f:read("*a")

end

-- 2 states returned, of type 'real', of dimensionality 1, from 0-1
function Minecraft:getStateSpec()
  local stateSpec = {'real', {3*self.histLen, self.height, self.width}, {0, 1}}

  return stateSpec
end

function Minecraft:getActionSpec()
  local actionSpec = {'int', 1, {1, #self.actions}}

  return actionSpec
end

-- Min and max reward
function Minecraft:getRewardSpec()
  return nil, nil
end

function Minecraft:getDisplaySpec()
  local displaySpec = {'real', {3, self.height, self.width}, {0, 1}}

  return displaySpec
end

function Minecraft:getDisplay()
  local display = {'real', {3, self.height, self.width}, {0, 1}}

  return display
end

-- process video input from the world
function Minecraft:processFrames(world_video_frames)

  local proc_frames = {}

  for frame in world_video_frames do
    local ti = torch.FloatTensor(3, self.height, self.width)
    getTorchTensorFromPixels(frame, tonumber(torch.cdata(ti, true)))
    ti = torch.div(ti, 255)
    table.insert(proc_frames, ti)
  end

  return proc_frames

end

function Minecraft:assembleState(hist)

  local state = torch.FloatTensor(self.histLen*3, self.height, self.width)

  for i = 1, self.histLen do
    state[{{(i-1)*3 + 1, i*3}, {}, {}}] = hist[i]
  end

  return state

end

function Minecraft:getRewards(world_rewards)

  local proc_rewards = {}

  for reward in world_rewards do
    table.insert(proc_rewards, reward:getValue())
  end

  return proc_rewards

end

-- Reset position
function Minecraft:start()

  local mission = MissionSpec(self.mission_xml, true)
  local mission_record = MissionRecordSpec()

  -- request video
  mission:requestVideo(self.height, self.width)

  -- channels, height, width of input frames
  local channels = mission:getVideoChannels(0)
  local height = mission:getVideoHeight(0)
  local width = mission:getVideoWidth(0)

  assert(channels == 3, "No RGB video output!")
  assert(height == self.height or width == self.width, "Video output dimensions don't match those requested!")

  -- set the time limit for mission (in seconds)
  mission:timeLimitInSeconds(self.time_limit)

  local status, err = pcall( function() self.agent_host:startMission( mission, mission_record ) end )
  if not status then
    print( "Error starting mission: "..err )
    os.exit(1)
  end

  io.write( "Waiting for mission to start" )
  local world_state = self.agent_host:getWorldState()
  while not world_state.has_mission_begun do
    io.write( "." )
    io.flush()
    sleep(0.1)
    world_state = self.agent_host:getWorldState()
    for error in world_state.errors do
      print("Error: "..error.text)
    end
  end
  io.write( "\n" )

  local proc_frames
  local hist = {}

  local world_state = self.agent_host:getWorldState()

  for error in world_state.errors do
    print("Error: "..error.text)
  end

  proc_frames = self:processFrames(world_state.video_frames)

  while #proc_frames < self.histLen do
    sleep(0.1)
    world_state = self.agent_host:peekWorldState()
    proc_frames = self:processFrames(world_state.video_frames)
  end

  -- store histLen number of frames in our frame history
  for i = 1, self.histLen do
    hist[i] = proc_frames[i]
  end

  -- assemble input frames into a state observation
  local state = self:assembleState(hist)
  
  sleep(0.1)

  return state
end

-- Move up, right, down or left
function Minecraft:step(action)

  -- do something
  local action = self.actions[action]
  self.agent_host:sendCommand(action)

  -- wait for world state to change
  sleep(0.1)

  -- check the world state
  local world_state = self.agent_host:peekWorldState()

  -- try to receive a reward
  local rewards = self:getRewards(world_state.rewards)

  -- if no reward received yet, keep trying
  while #rewards < 1 do
    sleep(0.1)
    world_state = self.agent_host:peekWorldState()
    rewards = self:getRewards(world_state.rewards)
  end

  local reward = rewards[1]

  local proc_frames
  local hist = {}

  proc_frames = self:processFrames(world_state.video_frames)

  while #proc_frames < self.histLen do
    sleep(0.1)
    world_state = self.agent_host:peekWorldState()
    proc_frames = self:processFrames(world_state.video_frames)
  end

  for i = 1, self.histLen do
    hist[i] = proc_frames[i]
  end

  local state = self:assembleState(hist)

  local terminal
  if not world_state.is_mission_running then
    terminal = true
  else
    terminal = false
  end
  
  sleep(0.1)

  return reward, state, terminal
end

return Minecraft
