local M = {}

-- Detect Hugo template files as gotmpl
function M.onInit()
  vim.filetype.add({
    pattern = {
      ['.*/layouts/.*%.html'] = 'gotmpl',
      ['.*/archetypes/.*%.md'] = 'gotmpl',
    }
  })
end

M.configureFormatter = function(conform)
  conform.formatters.oroshi_gotmpl_fix = {
    command = "gotmpl-fix",
    stdin = true,
    args = { "--piped", "--filepath", "$FILENAME" },
    exit_codes = { 0, 1 },
  }
end

return M
