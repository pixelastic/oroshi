local M = {}

M.onFiletype = function()
  -- Split words on dashes
  F.updateBufferOption("iskeyword", "@,48-57,_,192-255")
end

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

M.configureFormatter = function(conform)
  conform.formatters.oroshi_css_fix = {
    command = "css-fix",
    stdin = true,
    args = { "--piped", "--filepath", "$FILENAME" },
    exit_codes = { 0, 1 },
    timeout_ms = 10000,
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
      severity = M.__.convertSeverity(warning.severity),
      message = warning.text,
      source = "stylelint",
      code = warning.rule,
    }
  end))
end

-- Convert stylelint severity ("error", "warning") to vim.diagnostic severity
M.__ = {
  convertSeverity = function(severityString)
    return severityString == "warning" and vim.diagnostic.severity.WARN or vim.diagnostic.severity.ERROR
  end,
}

return M
