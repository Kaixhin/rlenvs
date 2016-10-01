local classic = require 'classic'

-- Uses rectangular bounding box collision checking (instead of pixels)
local XOWorld, super = classic.class('XOWorld', Env)

-- Constructor
function XOWorld:_init(opts)
  opts = opts or {}
  super._init(self, opts)

  -- Game mode (all circles, negative, or circles and crosses, negative and positive)
  self.double = opts.double or false
  -- Random or static positions
  self.random = opts.random or false

  -- Width and height
  self.size = 84
  self.screen = torch.Tensor(1, self.size, self.size):fill(1)
  self.collisions = torch.Tensor(1, self.size, self.size):fill(0)

  -- Timer
  self.time = 1
  self.timespan = 100 -- Number of steps per episode
  -- Training flag
  self.trainingFlag = true

  -- Object masks (inverse)
  -- Player (plus)
  self.player = torch.Tensor({{0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0},
                              {0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0},
                              {0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0},
                              {0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0},
                              {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
                              {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
                              {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
                              {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
                              {0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0},
                              {0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0},
                              {0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0},
                              {0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0}})
  -- Positive reward (cross)
  self.cross = torch.Tensor( {{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
                              {1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1},
                              {0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0},
                              {0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0},
                              {0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0},
                              {0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0},
                              {0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0},
                              {0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0},
                              {1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1},
                              {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
                              {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}})
  -- Negative reward (circle)
  self.circle = torch.Tensor({{0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0},
                              {0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0},
                              {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
                              {1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1},
                              {1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1},
                              {1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1},
                              {1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1},
                              {1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1},
                              {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
                              {0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0},
                              {0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0}})
  -- Object sizes
  self.playerSize = 12
  self.objectSize = 11
  self.randomInitSize = 13
  self.playerBox = torch.Tensor({{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
                                 {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
                                 {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
                                 {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
                                 {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
                                 {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
                                 {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
                                 {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
                                 {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
                                 {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
                                 {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
                                 {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}})
  self.objectBox = torch.Tensor({{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
                                 {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
                                 {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
                                 {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
                                 {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
                                 {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
                                 {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
                                 {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
                                 {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
                                 {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
                                 {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}})
  -- Object lists
  self.crosses = {}
  self.circles = {}
  
  -- Co-ordinates
  self.y = 36
  self.x = 36
  -- Static object positions
  self.staticCoords = { {7, 7},  {7, 27},  {7, 47},  {7, 67},
                       {27, 7}, {27, 27}, {27, 47}, {27, 67},
                       {47, 7}, {47, 27}, {47, 47}, {47, 67},
                       {67, 7}, {67, 27}, {67, 47}, {67, 67}}
end

-- 1 state returned, of type 'real', of dimensionality 3 x 210 x 160, between 0 and 1
function XOWorld:getStateSpace()
    local state = {}
    state['name'] = 'Box'
    state['shape'] = {1, self.size, self.size}
    state['low'] = {
        0
    }
    state['high'] = {
        1
    }
    return state
end

-- 1 action required, of type 'int', of dimensionality 1, between 0 and 3
function XOWorld:getActionSpace()
    local action = {}
    action['name'] = 'Discrete'
    action['n'] = 4
    return action
end

-- RGB screen of size self.size x self.size
function XOWorld:getDisplaySpec()
    return {'real', {3, self.size, self.size}, {0, 1}}
end

-- Min and max reward
function XOWorld:getRewardSpace()
    return -10, 10
end

-- Redraws screen based on state and performs collision detection
function XOWorld:update()
  local reward = 0
  local crossCollisionIndex, circleCollisionIndex

  -- Reset screen
  self.screen:fill(1)
  self.collisions:fill(0)
  -- Draw player
  self.screen[{{}, {self.y, self.y + self.playerSize - 1}, {self.x, self.x + self.playerSize - 1}}]:csub(self.player)
  self.collisions[{{}, {self.y, self.y + self.playerSize - 1}, {self.x, self.x + self.playerSize - 1}}]:add(self.playerBox)
  -- Draw objects
  for i = 1, #self.crosses do
    self.collisions[{{}, {self.crosses[i].y, self.crosses[i].y + self.objectSize - 1}, {self.crosses[i].x, self.crosses[i].x + self.objectSize - 1}}]:add(self.objectBox)
    -- Collision check
    if self.collisions:eq(2):sum() > 0 then
      -- Undo collision addition
      self.collisions[{{}, {self.crosses[i].y, self.crosses[i].y + self.objectSize - 1}, {self.crosses[i].x, self.crosses[i].x + self.objectSize - 1}}]:csub(self.objectBox)
      -- Save index of collided object
      crossCollisionIndex = i
      -- Update reward
      reward = 10
      -- Update counter
      if not self.trainingFlag then
        self.posCounter = self.posCounter + 1
      end
    else
      -- Add (subtract) object to screen
      self.screen[{{}, {self.crosses[i].y, self.crosses[i].y + self.objectSize - 1}, {self.crosses[i].x, self.crosses[i].x + self.objectSize - 1}}]:csub(self.cross)
    end
  end
  for i = 1, #self.circles do
    self.collisions[{{}, {self.circles[i].y, self.circles[i].y + self.objectSize - 1}, {self.circles[i].x, self.circles[i].x + self.objectSize - 1}}]:add(self.objectBox)
    -- Collision check
    if self.collisions:eq(2):sum() > 0 then
      -- Undo collision addition
      self.collisions[{{}, {self.circles[i].y, self.circles[i].y + self.objectSize - 1}, {self.circles[i].x, self.circles[i].x + self.objectSize - 1}}]:csub(self.objectBox)
      -- Save index of collided object
      circleCollisionIndex = i
      -- Update reward
      reward = -10
      -- Update counter
      if not self.trainingFlag then
        self.negCounter = self.negCounter + 1
      end
    else
      -- Add (subtract) object to screen
      self.screen[{{}, {self.circles[i].y, self.circles[i].y + self.objectSize - 1}, {self.circles[i].x, self.circles[i].x + self.objectSize - 1}}]:csub(self.circle)
    end
  end

  -- Clip screen (as objects can overlap)
  self.screen:clamp(0, 1)

  -- Remove collided objects
  if crossCollisionIndex then
    table.remove(self.crosses, crossCollisionIndex)
  end
  if circleCollisionIndex then
    table.remove(self.circles, circleCollisionIndex)
  end

  return reward
end

-- Starts new game
function XOWorld:_start()
  -- Reset time
  self.time = 1

  -- Reset player
  self.y = 36
  self.x = 36

  -- Reset objects
  self.crosses = {}
  self.circles = {}
  -- Add objects
  if self.random then
    -- Reset collisions
    self.collisions:fill(0)
    -- Draw player (for collision detection)
    self.collisions[{{}, {self.y - 1, self.y + self.playerSize - 1}, {self.x - 1, self.x + self.playerSize - 1}}]:add(1) -- randomInitSize "hard-coded"

    for i = 1, 14 do
      local coords = {}
      local collision = true
      while collision do
        coords = {torch.random(1, self.size - self.randomInitSize), torch.random(1, self.size - self.randomInitSize)}
        -- Attempt to add object and do object collision - add if successful for next round of collision detection
        if self.double then
          if i % 2 == 0 then
            if (self.collisions[{{}, {coords[2], coords[2] + self.randomInitSize - 1}, {coords[1], coords[1] + self.randomInitSize - 1}}] + 1):eq(2):sum() == 0 then
              self.collisions[{{}, {coords[2], coords[2] + self.randomInitSize - 1}, {coords[1], coords[1] + self.randomInitSize - 1}}]:add(1)
              collision = false
              self.crosses[#self.crosses + 1] = {x = coords[1] + 1, y = coords[2] + 1} -- More central
            end
          else
            if (self.collisions[{{}, {coords[2], coords[2] + self.randomInitSize - 1}, {coords[1], coords[1] + self.randomInitSize - 1}}] + 1):eq(2):sum() == 0 then
              self.collisions[{{}, {coords[2], coords[2] + self.randomInitSize - 1}, {coords[1], coords[1] + self.randomInitSize - 1}}]:add(1)
              collision = false
              self.circles[#self.circles + 1] = {x = coords[1] + 1, y = coords[2] + 1}
            end
          end
        else
          if (self.collisions[{{}, {coords[2], coords[2] + self.randomInitSize - 1}, {coords[1], coords[1] + self.randomInitSize - 1}}] + 1):eq(2):sum() == 0 then
            self.collisions[{{}, {coords[2], coords[2] + self.randomInitSize - 1}, {coords[1], coords[1] + self.randomInitSize - 1}}]:add(1)
            collision = false
            self.circles[#self.circles + 1] = {x = coords[1] + 1, y = coords[2] + 1}
          end
        end
      end
    end
  else
    for i = 1, #self.staticCoords do
      if self.double then
        if i == 2 or i == 4 or i == 5 or i == 7 or i == 10 or i == 12 or i == 13 or i == 15 then
          self.crosses[#self.crosses + 1] = {x = self.staticCoords[i][2], y = self.staticCoords[i][1]}
        else
          self.circles[#self.circles + 1] = {x = self.staticCoords[i][2], y = self.staticCoords[i][1]}
        end
      else
        self.circles[#self.circles + 1] = {x = self.staticCoords[i][2], y = self.staticCoords[i][1]}
      end
    end
  end
 
  -- Redraw screen
  self:update()

  -- Return observation
  return self.screen
end

-- Steps in a game
function XOWorld:_step(action)
  -- Move player
  if action == 0 then
    self.x = math.max(self.x - 1, 1)
  elseif action == 1 then
    self.x = math.min(self.x + 1, self.size - self.playerSize + 1)
  elseif action == 2 then
    self.y = math.max(self.y - 1, 1)
  else
    self.y = math.min(self.y + 1, self.size - self.playerSize + 1)
  end

  -- Redraw screen and get reward from collision detection
  local reward = self:update()

  -- Increase timer and check terminal
  self.time = self.time + 1
  local terminal = self.time == self.timespan
  
  return reward, self.screen, terminal
end

-- Returns (RGB) display of screen
function XOWorld:getDisplay()
  return torch.repeatTensor(self.screen, 3, 1, 1)
end

-- Changes timespan for training
function XOWorld:training()
  self.trainingFlag = true
  self.timespan = 100
end

-- Changes timespan for evaluation
function XOWorld:evaluate()
  self.trainingFlag = false
  self.timespan = 200
end

return XOWorld
