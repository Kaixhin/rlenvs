# rlenvs

Reinforcement learning environments for Torch7. Each environment implements at least a `step` method:

```lua
reward, observation, terminal = env:step(action)
```

Supported environments:
- Mountain Car

## Requirements

```sh
luarocks install https://raw.githubusercontent.com/deepmind/classic/master/rocks/classic-scm-1.rockspec
```
