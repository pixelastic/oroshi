local M = {}

-- Configure formatter
M.configureFormatter = function()
  -- local conform = require("conform")
  --
  -- -- Add custom formatter
  -- conform.formatters_by_ft.lua = { "stylua" }
  --
  -- -- Configure stylua
  -- conform.formatters.stylua = {
  --   prepend_args = {
  --     "--indent-type",
  --     "Spaces",
  --     "--indent-width",
  --     vim.o.shiftwidth,
  --   },
  -- }
end

-- Configure the Lua LSP server
M.configureLsp = function()
  -- require("lspconfig").lua_ls.setup({
  --   on_init = function(client)
  --     -- Make it aware of vim-specific globals
  --     local config = {
  --       runtime = { version = "LuaJIT" },
  --       workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
  --     }
  --     client.config.settings.Lua = F.merge(client.config.settings.Lua, config)
  --   end,
  -- })
end

return M
