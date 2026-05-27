local M = {}

-- Commit staged changes (vcc)
function M.gitCommitCreate()
  local neogit = require("neogit")
  neogit.open()
end

return M
