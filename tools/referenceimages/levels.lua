local chunk = require "chunk"

return load("return " .. chunk.getValue("levels"))()
