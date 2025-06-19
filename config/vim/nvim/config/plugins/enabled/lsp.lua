return {

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
