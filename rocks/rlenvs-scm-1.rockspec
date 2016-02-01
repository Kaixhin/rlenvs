package = "rlenvs"
version = "scm-1"

source = {
  url = "git://github.com/Kaixhin/rlenvs.git",
  branch = "master"
}

description = {
  summary = "Reinforcement learning environments for Torch7",
  detailed = [[
                Reinforcement learning environments for Torch7, inspired by RL-Glue
  ]],
  homepage = "https://github.com/Kaixhin/rlenvs",
  license = "MIT"
}

dependencies = {
  "torch >= 7.0",
  "classic"
}

build = {
  type = "builtin",
  modules = {
    rlenvs = "rlenvs/init.lua",
    ["rlenvs.Env"] = "rlenvs/Env.lua",
    ["rlenvs.Atari"] = "rlenvs/Atari.lua",
    ["rlenvs.Catch"] = "rlenvs/Catch.lua",
    ["rlenvs.MountainCar"] = "rlenvs/MountainCar.lua"
  }
}
