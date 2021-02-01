# Patato Man
A platform adventure video game, ported with [Löve2D](https://love2d.org/).

[![test](https://github.com/fbosio/patato/workflows/test/badge.svg)](https://github.com/fbosio/patato/actions)


## Engine usage
1. Clone/download this repo.
2. Copy `engine/` in your project's directory.
3. Create a `main.lua` file with the following line
   ```lua
   love.run = require "engine".run
   ```
4. Run `love .` in your project's directory.
