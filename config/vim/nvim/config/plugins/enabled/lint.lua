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
      "neovim/nvim-lspconfig",
      'echasnovski/mini.notify',
    },
    config = function()
      helper.loadServers()

      helper.configureDiagnostics()

      helper.configureDiagLine()
    end,
  },
  -- nvim-lint
  -- https://github.com/mfussenegger/nvim-lint
  -- Spawns linter asynchronously and display results
  -- This should be used only when LSP Diagnostics are not enough
  -- {
  --   "mfussenegger/nvim-lint",
  --   event = { "BufReadPre", "BufNewFile" },
  --   config = function()
  --     local lint = require("lint")
  --
  --     lint.linters_by_ft = {
  --       lua = { }
  --       -- javascript = { "eslint_d" },
  --       -- typescript = { "eslint_d" },
  --       -- javascriptreact = { "eslint_d" },
  --       -- typescriptreact = { "eslint_d" },
  --       -- svelte = { "eslint_d" },
  --       -- python = { "pylint" },
  --     }
  --
  --     local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
  --
  --     vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  --       group = lint_augroup,
  --       callback = function()
  --         lint.try_lint()
  --       end,
  --     })
  --
  --     vim.keymap.set("n", "<leader>l", function()
  --       lint.try_lint()
  --     end, { desc = "Trigger linting for current file" })
  --   end,
  -- },

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
