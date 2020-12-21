local entityTagger

before_each(
  function ()
    entityTagger = require "engine.tagger.entity"
  end
)

after_each(function ()
  package.loaded["engine.tagger.entity"] = nil
end)

describe("tagging an entity once", function ()
  local id

  before_each(function ()
    id = entityTagger.tag("player")
  end)

  it("should return an id when needed", function ()
    assert.are.same(id, entityTagger.getId("player"))
  end)

  it("should return the entity name when needed", function ()
    assert.are.same("player", entityTagger.getName(id))
  end)
end)

describe("tagging an entity twice", function ()
  it("should return nothing", function ()
    entityTagger.tag("player")
    entityTagger.tag("player")

    assert.are.falsy(entityTagger.getId("player"))
  end)
end)
