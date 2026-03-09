local M = {}

M.configureFormatter = function(conform)
  conform.formatters.oroshi_html_fix = {
    command = "html-fix",
    stdin = true,
    args = { "--piped", "--filepath", "$FILENAME" },
    exit_codes = { 0, 1 },
    timeout_ms = 10000,
  }
end

return M
