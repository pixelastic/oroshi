local M = {}

M.configureLinter = function(lint)
  lint.linters.oroshi_json_lint = {
    cmd = "json-lint",
    stdin = false,
    args = { "--json" },
    ignore_exitcode = true,
    parser = M.lintParser,
  }
end

-- Parser to convert CLI output to diagnostics
M.lintParser = function(output)
  local json = vim.json.decode(output)
  local result = F.first(json or {})
  if not result then
    return {}
  end

  local message = F.first(result.messages or {})
  if not message then
    return {}
  end

  return {
    {
      lnum = message.line - 1,
      col = message.column - 1,
      severity = vim.diagnostic.severity.ERROR,
      message = message.message,
      source = "json-lint",
      code = message.ruleId,
    },
  }
end

return M
