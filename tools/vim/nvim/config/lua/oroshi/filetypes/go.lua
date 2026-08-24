local M = {}
local codeQuality = require("oroshi/plugins/helpers/code-quality")

M.configureLinter = function(lint)
  lint.linters.oroshi_go_lint = {
    cmd = "bin-zsh",
    args = { "go-lint", "--json" },
    stdin = false,
    ignore_exitcode = true,
    parser = codeQuality.lintParser,
  }
end

M.configureFormatter = function(conform)
  conform.formatters.oroshi_go_fix = {
    command = "bin-zsh",
    stdin = false,
    args = { "go-fix", "$FILENAME", "--original-path", "$ORIGINAL_PATH" },
  }
end

return M
