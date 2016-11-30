# rlenvs

Reinforcement learning environments for Torch7, inspired by RL-Glue [[1]](#references). Supported environments:

- rlenvs.Acrobot [[2]](#references)
- rlenvs.Atari (Arcade Learning Environment)\* [[3]](#references)
- rlenvs.Blackjack [[4]](#references)
- rlenvs.CartPole [[5]](#references)
- rlenvs.Catch [[6]](#references)
- rlenvs.CliffWalking [[7]](#references)
- rlenvs.DynaMaze [[8]](#references)
- rlenvs.GridWorld [[9]](#references)
- rlenvs.JacksCarRental [[7]](#references)
- rlenvs.Minecraft (Project Malmö)\* [[10]](#references)
- rlenvs.MountainCar [[11]](#references)
- rlenvs.MultiArmedBandit [[12, 13]](#references)
- rlenvs.RandomWalk [[14]](#references)
- rlenvs.Taxi [[15]](#references)
- rlenvs.WindyWorld [[7]](#references)
- rlenvs.XOWorld [[16]](#references)

Run `th experiment.lua` (or `qlua experiment.lua`) to run a demo of a random agent playing Catch.

\* Environments with other dependencies are installed only if those dependencies are available.

## Installation

```sh
luarocks install https://raw.githubusercontent.com/Kaixhin/rlenvs/master/rocks/rlenvs-scm-1.rockspec
```

#### Atari Dependencies

```sh
luarocks install https://raw.githubusercontent.com/lake4790k/xitari/master/xitari-0-0.rockspec
luarocks install https://raw.githubusercontent.com/Kaixhin/alewrap/master/alewrap-0-0.rockspec
```

Requires a [supported](https://github.com/Kaixhin/Atari/blob/master/roms/README.md) Atari ROM to run.

#### Minecraft Dependencies

```sh
luarocks install luasocket
```

Requires [Malmö](https://github.com/Microsoft/malmo) (includes Minecraft), extracted with directory name `MalmoPlatform`. `libMalmoLua.so` should be added to `LUA_CPATH`, and the level schemas should be exported to `MALMO_XSD_PATH`. For example, if `MalmoPlatform` is in `/home/username`, add the following to the end of your `~/.bashrc`:

```sh
export LUA_CPATH='/home/username/MalmoPlatform/Torch_Examples/?.so;'$LUA_CPATH
export MALMO_XSD_PATH=/home/username/MalmoPlatform
```

The Malmö client (`launchClient.sh`) must be operating to run.

## Usage

To use an environment, `require` it and then create a new instance:

```lua
local MountainCar = require 'rlenvs.MountainCar'
local env = MountainCar()
local observation = env:start()
```

## API

**Note that the API is under development and may be subject to change**

### rlenvs.envs

A table of all possible environments implemented in rlenvs.

### observation = env:start([opts])

Starts a new episode in the environment and returns the first `observation`. May take `opts`.

### reward, observation, terminal, [actionTaken] = env:step(action)

Performs a step in the environment using `action` (which may be a list - see below), and returns the `reward`, the `observation` of the state transitioned to, and a `terminal` flag. Optionally provides `actionTaken`, if the environment provides supervision in the form of the actual action taken by the agent in spite of the provided action.

### stateSpec = env:getStateSpace()

Returns a state specification as a list with 3 elements:

| Type     | Dimensionality                                              | Range                                              |
|----------|-------------------------------------------------------------|----------------------------------------------------|
| 'int'    | 1 for a single value, or a table of dimensions for a Tensor | 2-element list with min and max values (inclusive) |
| 'real'   | 1 for a single value, or a table of dimensions for a Tensor | 2-element list with min and max values (inclusive) |
| 'string' | **TODO**                                                    | List of accepted strings                           |

If several states are returned, `stateSpec` is itself a list of state specifications. Ranges may use `nil` if unknown.

### actionSpec = env:getActionSpace()

Returns an action specification, with the same structure as used for state specifications.

### minReward, maxReward = env:getRewardSpace()

Returns the minimum and maximum rewards produced by the environment. Values may be `nil` if unknown.

---

The following are optional parts of the API.

### env:training()

Changes settings for a "training mode", analogous to neural network modules.

### env:evaluate()

Changes settings for an "evaluation mode", analogous to neural network modules.

### displaySpec = env:getDisplaySpec()

Returns an RGB display specification, with the same structure as used for state specifications. Hence of the form `{<int/real>, {3, <height>, <width>}, {<range>}}`.

### display = env:getDisplay()

Returns a RGB display tensor for visualising the state of the environment. Note that this may not be the same as the state provided for the agent.

## Development

Environments must inherit from `Env` and therefore implement the above methods (as well as a constructor). `experiment.lua` can be easily adapted for testing different environments. New environments should be added to `rlenvs/init.lua`, `rocks/rlenvs-scm-1.rockspec`, and be listed in this readme with an appropriate reference. For an example of a more complex environment that will only be installed if its optional dependencies are satisfied, see `rlenvs/Atari.lua`.

## References

[1] Tanner, B., & White, A. (2009). RL-Glue: Language-independent software for reinforcement-learning experiments. *The Journal of Machine Learning Research, 10*, 2133-2136.  
[2] DeJong, G., & Spong, M. W. (1994, June). Swinging up the acrobot: An example of intelligent control. In *American Control Conference, 1994* (Vol. 2, pp. 2158-2162). IEEE.  
[3] Bellemare, M. G., Naddaf, Y., Veness, J., & Bowling, M. (2012). The arcade learning environment. *J. Artificial Intelligence Res, 47*, 253-279.  
[4] Pérez-Uribe, A., & Sanchez, E. (1998, May). Blackjack as a test bed for learning strategies in neural networks. In *Neural Networks Proceedings, 1998. IEEE World Congress on Computational Intelligence. The 1998 IEEE International Joint Conference on* (Vol. 3, pp. 2022-2027). IEEE.  
[5] Barto, A. G., Sutton, R. S., & Anderson, C. W. (1983). Neuronlike adaptive elements that can solve difficult learning control problems. *Systems, Man and Cybernetics, IEEE Transactions on*, (5), 834-846.  
[6] Mnih, V., Heess, N., & Graves, A. (2014). Recurrent models of visual attention. In *Advances in Neural Information Processing Systems* (pp. 2204-2212).  
[7] Sutton, R. S., & Barto, A. G. (1998). *Reinforcement learning: An introduction* (Vol. 1, No. 1). Cambridge: MIT press.  
[8] Sutton, R. S. (1990). Integrated architectures for learning, planning, and reacting based on approximating dynamic programming. In *Proceedings of the seventh international conference on machine learning* (pp. 216-224).  
[9] Boyan, J., & Moore, A. W. (1995). Generalization in reinforcement learning: Safely approximating the value function. *Advances in neural information processing systems*, 369-376.  
[10] Johnson, M., Hofmann, K., Hutton, T., & Bignell, D. (2016). The Malmo platform for artificial intelligence experimentation. In *International joint conference on artificial intelligence (IJCAI)*.  
[11] Singh, S. P., & Sutton, R. S. (1996). Reinforcement learning with replacing eligibility traces. *Machine learning, 22*(1-3), 123-158.  
[12] Robbins, H. (1985). Some aspects of the sequential design of experiments. In *Herbert Robbins Selected Papers* (pp. 169-177). Springer New York.  
[13] Whittle, P. (1988). Restless bandits: Activity allocation in a changing world. *Journal of applied probability*, 287-298.  
[14] Sutton, R. S. (1988). Learning to predict by the methods of temporal differences. *Machine learning, 3*(1), 9-44.  
[15] Dietterich, T. G. (2000). Hierarchical Reinforcement Learning with the MAXQ Value Function Decomposition. In *Journal of Artificial Intelligence Research*.  
[16] Garnelo, M., Arulkumaran, K., & Shanahan, M. (2016). Towards Deep Symbolic Reinforcement Learning. *arXiv preprint arXiv:1609.05518*.  
