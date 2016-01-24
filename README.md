# rlenvs

Reinforcement learning environments for Torch7, inspired by RL-Glue [[1]](#references). Supported environments:

- rlenvs.Atari (Arcade Learning Environment)\* [[2]](#references)
- rlenvs.Blackjack
- rlenvs.Catch
- rlenvs.CartPole [[3]](#references)
- rlenvs.JacksCarRental [[4]](#references)
- rlenvs.MountainCar [[5]](#references)
- rlenvs.MultiArmedBandit [[6, 7]](#references)
- rlenvs.RandomWalk [[8]](#references)

Run `th experiment.lua` (or `qlua experiment.lua`) to run a demo of a random agent playing Catch.

\* Environments with other dependencies are installed only if those dependencies are available.

## Installation

```sh
luarocks install https://raw.githubusercontent.com/deepmind/classic/master/rocks/classic-scm-1.rockspec
luarocks install https://raw.githubusercontent.com/Kaixhin/rlenvs/master/rocks/rlenvs-scm-1.rockspec
```

#### Atari Dependencies
```sh
luarocks install https://raw.githubusercontent.com/Kaixhin/xitari/master/xitari-0-0.rockspec
luarocks install https://raw.githubusercontent.com/Kaixhin/alewrap/master/alewrap-0-0.rockspec
```

## Usage

To use an environment, `require` it and then create a new instance:

```lua
local MountainCar = require 'rlenvs.MountainCar'
local env = MountainCar()
local observation = env:start()
```

## API

**Note that the API is under development and may be subject to change**

Environments must inherit from `Env` and therefore implement the following methods (as well as a constructor):

### observation = env:start([opts])

Starts a new episode in the environment and returns the first `observation`. May take `opts`.

### reward, observation, terminal = env:step(action)

Performs a step in the environment using `action` (which may be a list - see below), and returns the `reward`, the `observation` of the state transitioned to, and a `terminal` flag.

### stateSpec = env:getStateSpec()

Returns a state specification as a list with 3 elements:

| Type     | Dimensionality                                              | Range                                              |
|----------|-------------------------------------------------------------|----------------------------------------------------|
| 'int'    | 1 for a single value, or a table of dimensions for a Tensor | 2-element list with min and max values (inclusive) |
| 'real'   | 1 for a single value, or a table of dimensions for a Tensor | 2-element list with min and max values (inclusive) |
| 'string' | **TODO**                                                    | List of accepted strings                           |

If several states are returned, `stateSpec` is itself a list of state specifications.

### actionSpec = env:getActionSpec()

Returns an action specification, with the same structure as used for state specifications.

### minReward, maxReward = env:getRewardSpec()

Returns the minimum and maximum rewards produced by the environment.

## References

[1] Tanner, B., & White, A. (2009). RL-Glue: Language-independent software for reinforcement-learning experiments. *The Journal of Machine Learning Research, 10*, 2133-2136.  
[2] Bellemare, M. G., Naddaf, Y., Veness, J., & Bowling, M. (2012). The arcade learning environment. *J. Artificial Intelligence Res, 47*, 253-279.  
[3] Barto, A. G., Sutton, R. S., & Anderson, C. W. (1983). Neuronlike adaptive elements that can solve difficult learning control problems. *Systems, Man and Cybernetics, IEEE Transactions on*, (5), 834-846.  
[4] Sutton, R. S., & Barto, A. G. (1998). *Reinforcement learning: An introduction* (Vol. 1, No. 1). Cambridge: MIT press.  
[5] Singh, S. P., & Sutton, R. S. (1996). Reinforcement learning with replacing eligibility traces. *Machine learning, 22*(1-3), 123-158.  
[6] Robbins, H. (1985). Some aspects of the sequential design of experiments. In *Herbert Robbins Selected Papers* (pp. 169-177). Springer New York.  
[7] Whittle, P. (1988). Restless bandits: Activity allocation in a changing world. *Journal of applied probability*, 287-298.  
[8] Sutton, R. S. (1988). Learning to predict by the methods of temporal differences. *Machine learning, 3*(1), 9-44.
