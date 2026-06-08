local M = {}

M.linters = { "bats-lint" }

M.onInit = function()
  -- Use bash treesitter parser for syntax highlighting
  vim.treesitter.language.register("bash", "bats")
  -- Force bats as bats, not sh
  F.onRead("*.bats", function()
    F.updateBufferOption("filetype", "bats")
  end)
end

M.configureLinter = function(lint)
  lint.linters["bats-lint"] = {
    cmd = "bats-lint",
    stdin = false,
    ignore_exitcode = true,
    parser = M.lintParser,
  }
end

-- Parser to convert CLI output to diagnostics
M.lintParser = function(output)
  if output == "" then
    return {}
  end
  local decoded = vim.json.decode(output)
  local diagnostics = {}
  for _, item in ipairs(decoded or {}) do
    F.append(diagnostics, {
      source = "bats-lint",
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
