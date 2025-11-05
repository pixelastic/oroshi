local M = {}

local helper = O_require("oroshi/plugins/helpers/code-quality")

M.configureLsp = function()
  -- Check .luarc.json for details of the exact config. This applies only to
  -- .lua files used to configure Neovim.
  helper.configureLspServer("lua_ls", {})
end

M.configureFormatter = function(conform)
  conform.formatters.stylua = {
    prepend_args = {
      "--indent-type",
      "Spaces",
      "--indent-width",
      vim.o.shiftwidth,
    },
  }
end

return M
