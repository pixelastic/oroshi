local M = {}

local helper = O_require("oroshi/plugins/helpers/code-quality")

M.configureLsp = function()
  helper.configureLspServer("lua_ls", {
    on_init = function(client)
      local config = {
        runtime = { version = "LuaJIT" },
        workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
      }
      client.config.settings.Lua = F.merge(client.config.settings.Lua or {}, config)
    end,
  })
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
