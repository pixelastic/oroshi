local M = {}

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

M.convertSeverity = function(jsonSeverity)
  return jsonSeverity == 1 and vim.diagnostic.severity.WARN or vim.diagnostic.severity.ERROR
end

return M
