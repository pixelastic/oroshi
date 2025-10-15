local M = {}

-- Configure linter if not already configured
M.configureLinter = function(lint)
  if lint.linters.oroshi_js_lint then
    return -- Already configured
  end
  
  lint.linters.oroshi_js_lint = {
    cmd = "js-lint",
    stdin = false,
    args = { "--json" },
    ignore_exitcode = true,
    parser = M.lintParser,
  }
end

-- Configure formatter if not already configured
M.configureFormatter = function(conform)
  if conform.formatters.oroshi_js_fix then
    return -- Already configured
  end
  
  conform.formatters.oroshi_js_fix = {
    command = "js-fix",
    stdin = true,
    args = { "--filepath", "$FILENAME" },
    exit_codes = { 0, 1 }, -- Do not fail on unfixable errors
    timeout_ms = 5000, -- JS/TS can be slow...
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
  return F.compact(F.map(result.messages or {}, function(message)
    -- Skip lines already handled (we only need to display one error per line)
    local line = message.line
    if seenLines[line] then
      return false
    end
    seenLines[line] = true

    return {
      lnum = line - 1,
      col = message.column - 1,
      severity = M.convertSeverity(message.severity),
      message = message.message,
      source = "eslint",
      code = message.ruleId,
    }
  end))
end

-- Convert eslint severity (1 = warning, 2 = error) to vim.diagnostic severity
M.convertSeverity = function(jsonSeverity)
  return jsonSeverity == 1 and vim.diagnostic.severity.WARN or vim.diagnostic.severity.ERROR
end

return M
