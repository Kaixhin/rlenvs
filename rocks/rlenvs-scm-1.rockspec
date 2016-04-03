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
  "image",
  "classic"
}

build = {
  type = "builtin",
  modules = {
    rlenvs = "rlenvs/init.lua",
    ["rlenvs.Env"] = "rlenvs/Env.lua",
    ["rlenvs.Acrobot"] = "rlenvs/Acrobot.lua",
    ["rlenvs.Atari"] = "rlenvs/Atari.lua",
    ["rlenvs.Blackjack"] = "rlenvs/Blackjack.lua",
    ["rlenvs.CartPole"] = "rlenvs/CartPole.lua",
    ["rlenvs.Catch"] = "rlenvs/Catch.lua",
    ["rlenvs.CliffWalking"] = "rlenvs/CliffWalking.lua",
    ["rlenvs.DynaMaze"] = "rlenvs/DynaMaze.lua",
    ["rlenvs.GridWorld"] = "rlenvs/GridWorld.lua",
    ["rlenvs.JacksCarRental"] = "rlenvs/JacksCarRental.lua",
    ["rlenvs.MountainCar"] = "rlenvs/MountainCar.lua",
    ["rlenvs.MultiArmedBandit"] = "rlenvs/MultiArmedBandit.lua",
    ["rlenvs.RandomWalk"] = "rlenvs/RandomWalk.lua",
    ["rlenvs.Taxi"] = "rlenvs/Taxi.lua",
    ["rlenvs.WindyWorld"] = "rlenvs/WindyWorld.lua"
  }
}
