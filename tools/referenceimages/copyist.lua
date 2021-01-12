local M = {}

function M.write(origins)
  local buffer = {"local M = {}\n"}
  for k, v in pairs(origins) do
    buffer[#buffer + 1] = "M." .. k .. " = {\n"
                          .. '  spriteSheet = "resources/' .. k .. '.png",\n'
                          .. "  sprites = {\n"
                          .. "    {" .. v[1] .. ", " .. v[2] .. "}\n"
                          .. "  },\n"
                          .. "  animations = {\n"
                          .. "    {1, 1}\n"
                          .. "  }\n"
                          .. "}"
  end
  buffer[#buffer + 1] = "\nreturn M\n"

  local file = assert(io.open("resources/levels.lua", "w"))
  file:write(table.concat(buffer, "\n"))
  file:close()
end

return M
