assert(table.getn(arg) >= 1, [[
Invalid input. Bootstrap usage is:

  lua bootstrap.lua "<a.lua>;<b.lua>;<c.lua>..."
]])

require 'luaspec'
require 'luamock'

for _, file in ipairs(arg) do
  require(file)
end

spec:report(true)
