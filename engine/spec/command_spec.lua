local command, hid, components

before_each(function ()
  command = require "engine.command"
  hid = {}
  components = {}
  command.load(hid, components)
end)

after_each(function ()
  package.loaded["engine.command"] = nil
end)

describe("setting a hold command for an entity", function ()
  it("should map the entity to the command", function ()
    
  end)
end)
