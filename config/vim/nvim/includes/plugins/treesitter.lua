return {
  -- https://github.com/nvim-treesitter/nvim-treesitter
  -- Highlight, indent, folding, AST
  -- enabled = false,
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

    -- Use treesitter for folding specific files
    ftplugin(
      { "bash", "css", "csv", "dockerfile", "editorconfig", "html", 
        "ini", "javascript", "json", "lua", "markdown", "nginx", "pug", 
        "ruby", "xml", "yaml" },
      function()
        vim.opt_local.foldmethod = 'expr'
        vim.opt_local.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      end
    )
  end,
}
