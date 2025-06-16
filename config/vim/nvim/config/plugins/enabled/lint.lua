local helperLsp = O_require('oroshi/plugins/helpers/lint/lsp')
local helperDiagline = O_require('oroshi/plugins/helpers/lint/diagline')
local helperStatusline = O_require('oroshi/plugins/helpers/lint/statusline')
local helperZsh = O_require('oroshi/plugins/helpers/lint/zsh')

return {
  -- LSP
  -- Installs LSP servers and configure them.
  -- https://github.com/mason-org/mason.nvim
  -- https://github.com/mason-org/mason-lspconfig.nvim
  -- https://github.com/neovim/nvim-lspconfig
  --
  -- LSP servers are complex dynamic systems that understand code as we type.
  -- They can be used for auto-completion, type definition, linting,
  -- refactoring, etc
  {
    "mason-org/mason.nvim",
    dependencies = {
      "mason-org/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig"
    },
    config = function()
      -- Install and load servers
      helperLsp.init()

      -- Configure diag line
      helperDiagline.init()

      -- Configure display in the statusline
      helperStatusline.init()
    end,
  },
  -- nvim-lint
  -- https://github.com/mfussenegger/nvim-lint
  -- Spawns linter asynchronously and display results
  -- This should be used only when LSP Diagnostics are not enough
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters = {}
      lint.linters_by_ft = {}

      helperZsh.init()

      F.autocmd({"BufEnter", "BufWritePost", "InsertLeave"}, function()
        lint.try_lint()
      end)
    end,
  },

  -- mini.trailspace
  -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-trailspace.md
  -- Remove trailing spaces on save
  {
    'echasnovski/mini.trailspace',
    version = '*',
    config = function()
      local trailspace = require('mini.trailspace')
      F.autocmd('BufWritePre', function()
        trailspace.trim()            -- Remove trailing spaces
        trailspace.trim_last_lines() -- Remove trailing lines
      end)
    end
  },

  -- Conform
  -- https://github.com/stevearc/conform.nvim
  -- Format code automatically
  -- {
  --   'stevearc/conform.nvim',
  --   config = function()
  --     require("conform").setup({
  --       formatters_by_ft = {
  --         lua = { "stylua" },
  --       },
  --     })
  --   end
  -- }
}
