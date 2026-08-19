local M = {}

M.configureLinter = function(lint)
  lint.linters.oroshi_go_lint = {
    cmd = "bin-zsh",
    args = { "go-lint" },
    stdin = false,
    ignore_exitcode = true,
    parser = M.lintParser,
  }
end

M.configureFormatter = function(conform)
  conform.formatters.oroshi_go_fix = {
    command = "bin-zsh",
    stdin = true,
    args = { "go-fix", "--filepath", "$FILENAME" },
  }
end

-- Parser to convert go-lint JSON output to diagnostics
-- go-lint uses the same unified format as bats-lint and zsh-lint:
-- [
--   {
--     "code": "staticcheck",
--     "level": "error",
--     "line": 1,
--     "endLine": 1,
--     "column": 0,
--     "endColumn": 0,
--     "message": "..."
--   }
-- ]
M.lintParser = function(output)
  if output == "" then
    return {}
  end
  local decoded = vim.json.decode(output)
  local diagnostics = {}
  for _, item in ipairs(decoded or {}) do
    F.append(diagnostics, {
      source = "go-lint",
      code = item.code,
      message = item.message,
      severity = M.__.severityStringToInt(item.level),

      lnum = item.line - 1,
      end_lnum = item.endLine - 1,
      col = item.column - 1,
      end_col = item.endColumn - 1,
      user_data = {
        lsp = {
          code = item.code,
        },
      },
    })
  end
  return diagnostics
end

M.__ = {
  severityStringToInt = function(severityString)
    local severities = {
      error = vim.diagnostic.severity.ERROR,

      warning = vim.diagnostic.severity.WARN,
      warn = vim.diagnostic.severity.WARN,

      info = vim.diagnostic.severity.INFO,

      style = vim.diagnostic.severity.HINT,
      hint = vim.diagnostic.severity.HINT,

      success = 5,
    }
    return severities[severityString]
  end,
}

return M
