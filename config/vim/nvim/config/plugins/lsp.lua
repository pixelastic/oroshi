return {
  -- LSP
  -- We will install LSP servers through Mason, and configure them through
  -- mason-lspconfig
  -- LSP servers are complex dynamic systems that understand code.
  -- They can be used for auto-completion, type definition, linting,
  -- refactoring, etc
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

  -- Treesitter
  -- https://github.com/nvim-treesitter/nvim-treesitter
  -- Treesitter is fast and static, and understands the structure of code.
  -- It can be used for highlight, indentation, folding, etc
  {
    "nvim-treesitter/nvim-treesitter",
    version = "0.25.4",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
      local treesitter = require("nvim-treesitter.configs")

      treesitter.setup({
        ensure_installed = {
          "bash",
          "comment",
          "css",
          "csv",
          "diff",
          "dockerfile",
          "editorconfig",
          "gitignore",
          "git_config",
          "html",
          "ini",
          "javascript",
          "jsdoc",
          "json",
          "lua",
          "markdown",
          "markdown_inline",
          "nginx",
          "pug",
          "regex",
          "robots",
          "ruby",
          "ssh_config",
          "xml",
          "yaml"
        },

        highlight = {
          -- Advanced syntax highlight
          enable = true,
          additional_vim_regex_highlighting = false
        },

        -- Select node with vv (then expand with CTRL-J / CTRL-K)
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "vv",     -- Select node
            node_incremental = "<C-K>", -- Select parent node
            node_decremental = "<C-J>", -- Deselect parent node
            scope_incremental = false
          },
        },

        -- Indent selection with =
        indent = { 
          enable = true 
        }, 
      })
    end,
  }
}
