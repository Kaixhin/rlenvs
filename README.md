# rlenvs

Reinforcement learning environments for Torch7, inspired by RL-Glue [[1]](#references). Supported environments:

- rlenvs.Atari (Arcade Learning Environment) [[2]](#references)
- rlenvs.Catch
- rlenvs.MountainCar [[3]](#references)

Run `th experiment.lua` (or `qlua experiment.lua`) to run a demo of a random agent playing Catch.

## Installation

```sh
# Dependencies
luarocks install https://raw.githubusercontent.com/deepmind/classic/master/rocks/classic-scm-1.rockspec

# Atari (Arcade Learning Environment) dependencies
luarocks install https://raw.githubusercontent.com/Kaixhin/xitari/master/xitari-0-0.rockspec
luarocks install https://raw.githubusercontent.com/Kaixhin/alewrap/master/alewrap-0-0.rockspec

# rlenvs
luarocks install https://raw.githubusercontent.com/Kaixhin/rlenvs/master/rocks/rlenvs-scm-1.rockspec
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
[3] Singh, S. P., & Sutton, R. S. (1996). Reinforcement learning with replacing eligibility traces. *Machine learning, 22*(1-3), 123-158.  
