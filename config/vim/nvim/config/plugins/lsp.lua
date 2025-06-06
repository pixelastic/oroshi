return {
  -- Mason
  {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      -- Init mason
      require("mason").setup()

      -- Lua LSP (with understanding of vim globals)
      require('lspconfig').lua_ls.setup({
        settings = { Lua = {} },
        on_init = function(client)
          local config = {
            runtime = { version = 'LuaJIT' },
            workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } }
          }
          client.config.settings.Lua = F.merge(client.config.settings.Lua, config)
        end,
      })

      -- Install and load LSP configs.
      -- Full list available on:
      -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
      local masonLspconfig = require("mason-lspconfig")
      masonLspconfig.setup({
        ensure_installed = {
          "lua_ls",
        },
      })

      -- Configure diagnostics
      vim.diagnostic.config({
        signs = false,
        virtual_text = { 
          prefix = '█',
          current_line = true 
        },
        signs = {
          numhl = {
            [vim.diagnostic.severity.ERROR] = 'DiagnosticLineNrError',
            [vim.diagnostic.severity.WARN] = 'DiagnosticLineNrWarn',
            [vim.diagnostic.severity.INFO] = 'DiagnosticLineNrInfo',
            [vim.diagnostic.severity.HINT] = 'DiagnosticLineNrHint',
          },
        },
      })


    end,
  },
}
