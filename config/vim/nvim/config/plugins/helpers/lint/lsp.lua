local M = {}
-- Install, load and configure all LSP servers
-- Full list available on:
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
M.init = function(lspServers)
  -- Specific LSP servers need to be configured before being installed
  M.configureLuaServer()

  require("mason-lspconfig").setup({
    ensure_installed = lspServers
  })
end

-- Configure the Lua LSP server
M.configureLuaServer = function()
  require('lspconfig').lua_ls.setup({
    on_init = function(client)
      -- Make it aware of vim-specific globals
      local config = {
        runtime = { version = 'LuaJIT' },
        workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } }
      }
      client.config.settings.Lua = F.merge(client.config.settings.Lua, config)
    end,
  })
end

return M
