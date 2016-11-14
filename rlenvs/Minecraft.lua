local classic = require 'classic'
local image = require 'image'
-- Do not install if luasocket missing
local hasSocket, socket = pcall(require, 'socket')
if not hasSocket then
  return nil
end
-- Install without libMalmoLua, check at runtime
local hasLibMalmoLua, libMalmoLua = pcall(require, 'libMalmoLua')

local Minecraft, super = classic.class('Minecraft', Env)

local function sleep(sec)
  socket.select(nil, nil, sec)
end

-- Constructor
function Minecraft:_init(opts)
  if not hasLibMalmoLua then
    print("Requires libMalmoLua.so in the same folder")
    os.exit()
  end

  self.opts = opts or {}
  self.height = opts.height or 84
  self.width = opts.width or 84

  self.mission_xml = opts.mission_xml or [[<?xml version="1.0" encoding="UTF-8" ?>
<Mission xmlns="http://ProjectMalmo.microsoft.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <About>
    <Summary>Find the goal!</Summary>
  </About>

  <ServerSection>
    <ServerInitialConditions>
      <Time>
        <StartTime>6000</StartTime>
        <AllowPassageOfTime>false</AllowPassageOfTime>
      </Time>
      <Weather>clear</Weather>
      <AllowSpawning>false</AllowSpawning>
    </ServerInitialConditions>
    <ServerHandlers>
      <FlatWorldGenerator generatorString="3;7,220*1,5*3,2;3;,biome_1" />
      <ClassroomDecorator seed="__SEED__">
        <specification>
          <width>7</width>
          <height>7</height>
          <length>7</length>
          <pathLength>0</pathLength>
          <divisions>
            <southNorth>0</southNorth>
            <eastWest>0</eastWest>
            <aboveBelow>0</aboveBelow>
          </divisions>
          <horizontalObstacles>
            <gap>0</gap>
            <bridge>0</bridge>
            <door>0</door>
            <puzzle>0</puzzle>
            <jump>0</jump>
          </horizontalObstacles>
          <verticalObstacles>
            <stairs>0</stairs>
            <ladder>0</ladder>
            <jump>0</jump>
          </verticalObstacles>
          <hintLikelihood>1</hintLikelihood>
        </specification>
      </ClassroomDecorator>
      <ServerQuitFromTimeUp timeLimitMs="30000" description="out_of_time" />
      <ServerQuitWhenAnyAgentFinishes />
    </ServerHandlers>
  </ServerSection>

  <AgentSection mode="Survival">
    <Name>James Bond</Name>
    <AgentStart>
      <Placement x="-203.5" y="81.0" z="217.5" />
    </AgentStart>
    <AgentHandlers>
      <VideoProducer want_depth="false">
        <Width>160</Width>
        <Height>160</Height>
      </VideoProducer>
      <ObservationFromFullStats />
      <ContinuousMovementCommands turnSpeedDegs="180">
        <ModifierList type="deny-list">
          <command>attack</command>
        </ModifierList>
      </ContinuousMovementCommands>
      <RewardForSendingCommand reward="0" />
      <RewardForMissionEnd>
        <Reward description="found_goal" reward="100" />
        <Reward description="out_of_time" reward="-100" />
      </RewardForMissionEnd>
      <RewardForTouchingBlockType>
        <Block type="gold_ore diamond_ore redstone_ore" reward="20" />
      </RewardForTouchingBlockType>
      <AgentQuitFromTouchingBlockType>
        <Block type="gold_block diamond_block redstone_block" description="found_goal" />
      </AgentQuitFromTouchingBlockType>
    </AgentHandlers>
  </AgentSection>
</Mission>
]]

  self.time_limit = opts.time_limit or 10
  self.actions = opts.actions or {"move 1", "move -1", "turn 1", "turn -1"}

  self.agent_host = AgentHost()

  -- Load mission XML from provided file
  if opts.mission_xml then
    print("Loading mission XML from: " .. self.mission_xml)
    local f = assert(io.open(self.mission_xml, "r"), "Error loading mission")
    self.mission_xml = f:read("*a")
  end
end

-- 2 states returned, of type 'real', of dimensionality 1, from 0-1
function Minecraft:getStateSpec()
  return {'real', {3, self.height, self.width}, {0, 1}}
end

function Minecraft:getActionSpec()
  return {'int', 1, {1, #self.actions}}
end

-- Min and max reward
function Minecraft:getRewardSpec()
  return nil, nil
end

function Minecraft:getDisplaySpec()
  return {'real', {3, self.height, self.width}, {0, 1}}
end

function Minecraft:getDisplay()
  return {'real', {3, self.height, self.width}, {0, 1}} -- TODO: Fix
end

-- process video input from the world
function Minecraft:processFrames(world_video_frames)
  local proc_frames = {}

  for frame in world_video_frames do
    local ti = torch.FloatTensor(3, self.height, self.width)
    getTorchTensorFromPixels(frame, tonumber(torch.cdata(ti, true)))
    ti:div(255)
    table.insert(proc_frames, ti)
  end

  return proc_frames
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

  -- Request video
  mission:requestVideo(self.height, self.width)

  -- Channels, height, width of input frames
  local channels = mission:getVideoChannels(0)
  local height = mission:getVideoHeight(0)
  local width = mission:getVideoWidth(0)

  assert(channels == 3, "No RGB video output")
  assert(height == self.height or width == self.width, "Video output dimensions don't match those requested")

  -- Set the time limit for mission (in seconds)
  mission:timeLimitInSeconds(self.time_limit)

  local status, err = pcall( function() self.agent_host:startMission( mission, mission_record ) end )
  if not status then
    print("Error starting mission: "..err)
    os.exit(1)
  end

  io.write("Waiting for mission to start")
  local world_state = self.agent_host:getWorldState()
  while not world_state.has_mission_begun do
    io.write(".")
    io.flush()
    sleep(0.1)
    world_state = self.agent_host:getWorldState()
    for error in world_state.errors do
      print("Error: "..error.text)
    end
  end
  io.write("\n")

  local world_state = self.agent_host:getWorldState()

  for error in world_state.errors do
    print("Error: "..error.text)
  end

  local proc_frames = self:processFrames(world_state.video_frames)

  while #proc_frames < 1 do
    sleep(0.1)
    world_state = self.agent_host:peekWorldState()
    proc_frames = self:processFrames(world_state.video_frames)
  end

  sleep(0.1)

  return proc_frames[1]
end

-- Move up, right, down or left
function Minecraft:step(action)
  -- Do something
  local action = self.actions[action]
  self.agent_host:sendCommand(action)

  -- Wait for world state to change
  sleep(0.1)

  -- Check the world state
  local world_state = self.agent_host:peekWorldState()

  -- Try to receive a reward
  local rewards = self:getRewards(world_state.rewards)

  -- If no reward received yet, keep trying
  while #rewards < 1 do
    sleep(0.1)
    world_state = self.agent_host:peekWorldState()
    rewards = self:getRewards(world_state.rewards)
  end

  local reward = rewards[1]

  local proc_frames = self:processFrames(world_state.video_frames)

  while #proc_frames < 1 do
    sleep(0.1)
    world_state = self.agent_host:peekWorldState()
    proc_frames = self:processFrames(world_state.video_frames)
  end

  local state = proc_frames[1]

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
