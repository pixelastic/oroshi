local M = {}
local codeQuality = require("oroshi/plugins/helpers/code-quality")
local hasGoTemplateSyntax = O_require("oroshi/filetypes/gotmpl/hasGoTemplateSyntax")

M.onFiletype = function()
  local bufferId = F.bufferId()

  -- Auto-detect if is a GoTemplate
  local function checkGoTemplate()
    if hasGoTemplateSyntax() then
      F.updateBufferOption("filetype", "gotmpl", bufferId)
    end
  end

  F.autocmd({ "BufReadPost", "BufEnter", "BufWritePost" }, checkGoTemplate, { buffer = bufferId })
end

M.configureLinter = function(lint)
  lint.linters.oroshi_json_lint = {
    cmd = "bin-zsh",
    stdin = false,
    args = { "json-lint", "--json" },
    ignore_exitcode = true,
    parser = codeQuality.lintParser,
  }
end

M.configureFormatter = function(conform)
  conform.formatters.oroshi_json_fix = {
    command = "bin-zsh",
    stdin = false,
    args = function(_, ctx)
      return { "json-fix", "$FILENAME", "--original-path", ctx.filename }
    end,
  }
end

return M
