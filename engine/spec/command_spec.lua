local command

before_each(function ()
  command = require "engine.command"
end)

after_each(function ()
  package.loaded["engine.command"] = nil
end)

describe("with two commands with the same fields and values", function ()
  it("should considered both equal", function ()
    local oneCommand = command.new{key = "left", oneShot = false}
    local otherCommand = command.new{key = "left"}

    assert.are.equal(oneCommand, otherCommand)
  end)
end)
describe("with two commands with different fields and values", function ()
  it("should considered both different", function ()
    local oneCommand = command.new{key = "left", release = true}
    local otherCommand = command.new{key = "right"}

    assert.are_not.equal(oneCommand, otherCommand)
  end)
end)
