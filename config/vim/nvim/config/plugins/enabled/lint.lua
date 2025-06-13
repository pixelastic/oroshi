local helper = O_require('oroshi/plugins/helpers/lint')

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
      helper.loadServers()

      -- Configure vim diagnostics
      helper.configureDiagnostics()

      -- Configure display of the custom diag line
      helper.configureDiagLine()

      -- Configure display in the statusline
      helper.configureStatusline()
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

      helper.configureZshlint()

      lint.linters_by_ft = {
        zsh = { "zshlint" },
      }

      F.autocmd({"BufEnter", "BufWritePost", "InsertLeave"}, function()
        lint.try_lint()
      end)
    end,
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
