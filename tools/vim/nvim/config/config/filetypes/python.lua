local M = {}

-- Configure linter if not already configured
M.configureLinter = function(lint)
  lint.linters.oroshi_python_lint = {
    cmd = "python-lint",
    stdin = false,
    args = { "--json" },
    ignore_exitcode = true,
    parser = M.lintParser,
  }
end

-- Configure formatter if not already configured
M.configureFormatter = function(conform)
  conform.formatters.oroshi_python_fix = {
    command = "python-fix",
    stdin = true,
    args = { "--filepath", "$FILENAME" },
    exit_codes = { 0, 1 },
  }
end

-- Parser to convert Ruff JSON output to diagnostics
-- Ruff JSON format:
-- [
--   {
--     "code": "F401",
--     "message": "unused import",
--     "location": {"row": 1, "column": 0},
--     "end_location": {"row": 1, "column": 10},
--     "filename": "file.py"
--   }
-- ]
M.lintParser = function(output)
  local json = vim.json.decode(output)
  if not json or #json == 0 then
    return {}
  end

  local seenLines = {}
  return F.compact(F.map(json, function(violation)
    -- Skip lines already handled (we only need to display one error per line)
    local line = violation.location.row
    if seenLines[line] then
      return false
    end
    seenLines[line] = true

    return {
      lnum = line - 1,
      col = violation.location.column,
      severity = vim.diagnostic.severity.ERROR,
      message = violation.message,
      source = "ruff",
      code = violation.code,
    }
  end))
end

return M
