local M = {}

function M.write(origins)
  local buffer = {"return {"}
  for k, v in pairs(origins) do
    buffer[#buffer + 1] = "  " .. k .. " = {" .. v[1] .. ", " .. v[2] .. "},"
  end
  buffer[#buffer + 1] = "}\n"

  local file = assert(io.open("resources/levels.lua", "w"))
  file:write(table.concat(buffer, "\n"))
  file:close()
end

return M
