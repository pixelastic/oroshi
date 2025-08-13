local M = {}

M.configureFormatter = function()
  local conform = require("conform")

  -- Add custom formatter
  conform.formatters_by_ft.json = { "prettier" }
end

return M
