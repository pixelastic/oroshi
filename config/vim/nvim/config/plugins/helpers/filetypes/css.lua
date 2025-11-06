local M = {}

-- Configure linter if not already configured
M.configureLinter = function(lint)
  lint.linters.oroshi_css_lint = {
    cmd = "css-lint",
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

  local seenLines = {}
  return F.compact(F.map(result.warnings or {}, function(warning)
    -- Skip lines already handled (we only need to display one error per line)
    local line = warning.line
    if seenLines[line] then
      return false
    end
    seenLines[line] = true

    return {
      lnum = line - 1,
      col = warning.column - 1,
      severity = M.convertSeverity(warning.severity),
      message = warning.text,
      source = "stylelint",
      code = warning.rule,
    }
  end))
end

-- Convert stylelint severity ("error", "warning") to vim.diagnostic severity
M.convertSeverity = function(severityString)
  return severityString == "warning" and vim.diagnostic.severity.WARN or vim.diagnostic.severity.ERROR
end

return M
