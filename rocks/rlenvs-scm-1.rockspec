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
  "torch >= 7.0"
}

build = {
  type = "builtin",
  modules = {
    rlenvs = "rlenvs/init.lua",
    ["rlenvs.Env"] = "rlenvs/Env.lua",
    ["rlenvs.Catch"] = "rlenvs/Catch.lua"
  }
}
