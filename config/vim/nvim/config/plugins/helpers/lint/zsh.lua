local M = {}

M.init = function()
  local lint = require("lint")

  -- Add a new named linter
  lint.linters.zshlint = {
    cmd = "zshlint",
    stdin = false,
    ignore_exitcode = true,
    parser = M.parser
  }

  -- Use it
  lint.linters_by_ft.zsh = { "zshlint" }
end

-- Parser to convert CLI output to diagnostics
M.parser = function(output)
  if output == "" then return {} end
  local decoded = vim.json.decode(output)
  local diagnostics = {}
  for _, item in ipairs(decoded or {}) do
    local code = item.code
    local message = item.message

    -- [SC2154]
    -- This is a rule that flags unused variables. It cannot understand the
    -- zparseopts syntax to define variables from args passed to the
    -- commandline, so it flags some false positives. We will ignore it
    -- on purpose when the variable starts with flag*, which is the pattern I use
    if code == 2154 and F.startsWith(message, "flag") then
      goto continue
    end

    F.append(diagnostics, {
      source = "zshlint",
      code = "SC" .. item.code,
      message = item.message,
      severity = M.severityStringToInt(item.level),

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

    ::continue::
  end
  return diagnostics
end

M.severityStringToInt = function(severityString)
  local severities = {
    error = vim.diagnostic.severity.ERROR,

    warning = vim.diagnostic.severity.WARN,
    warn = vim.diagnostic.severity.WARN,

    info = vim.diagnostic.severity.INFO,

    style = vim.diagnostic.severity.HINT,
    hint = vim.diagnostic.severity.HINT,

    success = 5
  }
  return severities[severityString];
end

return M
