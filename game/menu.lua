local M = {}

function M.update(commands, callbacks, t)
  if commands.press.up then
    t.selected = t.selected - 1
    if t.selected == 0 then
      t.selected = #t.options
    end
  end
  if commands.press.down then
    t.selected = t.selected + 1
    if t.selected == #t.options + 1 then
      t.selected = 1
    end
  end
  if commands.press.start then
    callbacks[t.selected]()
  end
end

return M