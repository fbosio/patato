local M = {}

local dependencies = {
  collisionBox = "position",
  velocity = "position",
  gravitational = "velocity",
  collector = "collisionBox",
  collectable = "collisionBox",
  solid = "climber",
  collideable = "collisionBox",
  climber = {"collisionBox", "gravitational"},
  trellis = "collisionBox",
}

local function getDependencies(componentName, dependenciesSeq, i)
  local componentDependencies = dependencies[componentName]
  if not componentDependencies then return i end
  if type(componentDependencies) ~= "table" then
    componentDependencies = {componentDependencies}
  end

  for _, dependency in ipairs(componentDependencies) do
    dependenciesSeq[dependency] = i
    i = getDependencies(dependency, dependenciesSeq, i + 1)
  end
  return i
end

local function expandDependencies(componentName)
  local dependenciesSet = {}
  local iMax = getDependencies(componentName, dependenciesSet, 1)

  local transposed = {}
  for dependency, i in pairs(dependenciesSet) do
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

for componentName, _ in pairs(dependencies) do
  M[componentName] = function (components)
    return getIterator(componentName), components, nil
  end
end

return M
