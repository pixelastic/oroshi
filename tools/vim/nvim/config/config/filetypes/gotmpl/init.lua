
local M = {}

-- Parser to convert djlint CLI output to diagnostics
-- djlint format with --nvim flag:
-- 1:18|H025|Tag seems to be an orphan.
M.lintParser = function(output)
  local diagnostics = {}
  local lines = vim.split(output, "\n")

  for _, line in ipairs(lines) do
    -- Match pattern: LINE:COL|CODE|MESSAGE
    local lineCol, code, message = line:match("^(%d+:%d+)|(%S+)|(.+)$")
    if not lineCol or not code or not message then
      goto continue
    end

    local row, col = lineCol:match("(%d+):(%d+)")
    if not row or not col then
      goto continue
    end

    table.insert(diagnostics, {
      lnum = tonumber(row) - 1,
      col = tonumber(col) - 1,
      severity = vim.diagnostic.severity.ERROR,
      message = message,
      source = "djlint",
      code = code,
    })

    ::continue::
  end

  return diagnostics
end

M.configureLinter = function(lint)
  lint.linters.oroshi_gotmpl_lint = {
    cmd = "gotmpl-lint",
    stdin = false,
    args = { "--nvim" },
    ignore_exitcode = true,
    parser = M.lintParser,
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
