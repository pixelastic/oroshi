local M = {}
local codeQuality = require("oroshi/plugins/helpers/code-quality")

M.configureLinter = function(lint)
  lint.linters.oroshi_toml_lint = {
    cmd = "bin-zsh",
    args = { "toml-lint", "--json" },
    stdin = false,
    ignore_exitcode = true,
    parser = codeQuality.lintParser,
  }
end

M.configureFormatter = function(conform)
  conform.formatters.oroshi_toml_fix = {
    command = "bin-zsh",
    stdin = false,
    args = function(_, ctx)
      return { "toml-fix", "$FILENAME", "--original-path", ctx.filename }
    end,
  }
end

return M
