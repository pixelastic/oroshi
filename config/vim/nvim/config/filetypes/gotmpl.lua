local M = {}
local htmlHelper = O_require("oroshi/filetypes/html")

-- Detect Hugo template files as gotmpl
function M.onInit()
  vim.filetype.add({
    pattern = {
      ['.*/layouts/.*%.html'] = 'gotmpl',
      ['.*/archetypes/.*%.md'] = 'gotmpl',
    }
  })
end

M.configureLinter = function(lint)
  lint.linters.oroshi_gotmpl_lint = {
    cmd = "gotmpl-lint",
    stdin = false,
    args = { "--nvim" },
    ignore_exitcode = true,
    parser = htmlHelper.lintParser,
  }
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
