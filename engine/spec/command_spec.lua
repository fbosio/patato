local command

before_each(function ()
  command = require "engine.command"
end)

after_each(function ()
  package.loaded["engine.command"] = nil
end)

describe("creating two commands with the same key combinations", function ()
  it("should be considered equal", function ()
    local oneCommand = command.new{release = true, key = "left"}
    local otherCommand = command.new{release = true, key = "left"}

    assert.are.same(oneCommand, otherCommand)
  end)
end)
