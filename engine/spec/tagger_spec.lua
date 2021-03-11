local entityTagger

before_each(
  function ()
    entityTagger = require "engine.tagger"
  end
)

after_each(function ()
  package.loaded["engine.tagger"] = nil
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

  describe("and then removing the tag", function ()
    it("should return nil when trying to get the id", function ()
      entityTagger.remove(id)
      
      assert.is.falsy(entityTagger.getId("player"))
    end)
  end)
end)

describe("tagging an entity twice", function ()
  local id1, id2
  
  before_each(function ()
    id1 = entityTagger.tag("player")
    id2 = entityTagger.tag("player")
  end)

  describe("and getting an unique id", function ()
    it("should return the first id", function ()
      assert.are.same(id1, entityTagger.getId("player"))
    end)
  end)

  describe("and getting every id related to the entity", function ()
    it("should return the two ids used for the entity", function ()
      assert.are.same({id1, id2}, entityTagger.getIds("player"))
    end)
  end)

  describe("and then removing one id", function ()
    it("should return only the remaining id", function ()
      entityTagger.remove(id1)
      
      assert.are.same({id2}, entityTagger.getIds("player"))
    end)
  end)
end)
