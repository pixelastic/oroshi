local M = {}
local codeQuality = require("oroshi/plugins/helpers/code-quality")

-- Configure linter if not already configured
M.configureLinter = function(lint)
  lint.linters.oroshi_python_lint = {
    cmd = "bin-zsh",
    args = { "python-lint", "--json" },
    stdin = false,
    ignore_exitcode = true,
    parser = codeQuality.lintParser,
  }
end

-- Configure formatter if not already configured
M.configureFormatter = function(conform)
  conform.formatters.oroshi_python_fix = {
    command = "bin-zsh",
    stdin = false,
    args = function(_, ctx)
      return { "python-fix", "$FILENAME", "--original-path", F.bufferName(ctx.buf) }
    end,
  }
end

return M
