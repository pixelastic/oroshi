local M = {}
local codeQuality = require("oroshi/plugins/helpers/code-quality")

M.configureLinter = function(lint)
  lint.linters.oroshi_xml_lint = {
    cmd = "bin-zsh",
    args = { "xml-lint", "--json" },
    stdin = false,
    ignore_exitcode = true,
    parser = codeQuality.lintParser,
  }
end

M.configureFormatter = function(conform)
  conform.formatters.oroshi_xml_fix = {
    command = "bin-zsh",
    stdin = false,
    args = function(_, ctx)
      return { "xml-fix", "$FILENAME", "--original-path", ctx.filename }
    end,
  }
end

return M
