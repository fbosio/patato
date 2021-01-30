local M = {}

local dependencyTree = {
  solid = "climber",
  collideable = "collisionBox",
  collector = "collisionBox",
  collectable = "collisionBox",
  trellis = "collisionBox",
  climber = {"collisionBox", "gravitational"},
  camera = "collisionBox",
  limiter = "collisionBox",
  window = "collisionBox",
  gravitational = "velocity",
  velocity = "position",
  collisionBox = "position",
  animation = "position",
  -- Atoms
  position = {},
  garbage = {},
  menu = {},
  jukebox = {}
}

local function getDependencies(componentName, dependenciesSeq, i)
  local dependencies = dependencyTree[componentName]
  if not dependencies then return i end
  if type(dependencies) ~= "table" then
    dependencies = {dependencies}
  end
  for _, dependency in ipairs(dependencies) do
    dependenciesSeq[dependency] = i
    i = getDependencies(dependency, dependenciesSeq, i + 1)
  end
  return i
end

local function expandDependencies(componentName)
  local dependenciesSeq = {}
  local iMax = getDependencies(componentName, dependenciesSeq, 1)

  local transposed = {}
  for dependency, i in pairs(dependenciesSeq) do
    transposed[i] = dependency
  end

  local a = {}
  for i = 1, iMax do
    local dependency = transposed[i]
    if dependency then a[#a+1] = dependency end
  end
  return a
end

local function getIterator(componentName)
  local componentDependencies = expandDependencies(componentName)
  return function (components, entity)
    local component
    entity, component = next(components[componentName] or {}, entity)
    if not entity then return end
    local nextDependencies = {}
    for i, dependency in ipairs(componentDependencies) do
      nextDependencies[i] = (components[dependency] or {})[entity] or {}
    end
    if entity then return entity, component, unpack(nextDependencies) end
  end
end

for componentName, _ in pairs(dependencyTree) do
  M[componentName] = function (components)
    return getIterator(componentName), components, nil
  end
end

return M
