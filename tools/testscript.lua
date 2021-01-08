local spr = app.activeSprite
if not spr then
  app.alert("No active sprite")
  return
elseif #spr.tags == 0 then
  app.alert("No tags")
  return
end
-- #spr.layers is always greater than zero: no checking needed
local resetOriginLayer
for _, layer in ipairs(spr.layers) do
  if string.find(string.lower(layer.name), "^origins?$") then
    local wasVisible = layer.isVisible
    resetOriginLayer = function ()
      layer.isVisible = wasVisible
    end
    layer.isVisible = false
  end
end
if not resetOriginLayer then
  app.alert('No "Origin" layer')
  return
end
resetOriginLayer()
