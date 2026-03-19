local cssHelper = O_require("oroshi/filetypes/css")
local helperDiagline = O_require("oroshi/plugins/helpers/diagline")
local helperStatusline = O_require("oroshi/plugins/helpers/statusline")
local helper = O_require("oroshi/plugins/helpers/code-quality")
local htmlHelper = O_require("oroshi/filetypes/html")
local javascriptHelper = O_require("oroshi/filetypes/javascript")
local jsonHelper = O_require("oroshi/filetypes/json")
local luaHelper = O_require("oroshi/filetypes/lua")
local pythonHelper = O_require("oroshi/filetypes/python")
local tomlHelper = O_require("oroshi/filetypes/toml")
local zshHelper = O_require("oroshi/filetypes/zsh")

local config = {
  -- Dependencies to install globally
  dependencies = {
    -- Mason packages (LSP servers, formatters, linters)
    mason = {
      "lua-language-server",
      "prettier",
      "shfmt",
      "stylua",
      "taplo",
    },
    -- Treesitter parsers
    -- https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#supported-languages
    treesitter = {
      "bash",
      "comment",
      "css",
      "csv",
      "diff",
      "editorconfig",
      "gitignore",
      "git_config",
      "html",
      "ini",
      "javascript",
      "jsdoc",
      "jsonc",
      "json",
      "markdown",
      "markdown_inline",
      "nginx",
      "pug",
      "python",
      "regex",
      "robots",
      "ruby",
      "rust",
      "ssh_config",
      "tsx",
      "typescript",
      "vue",
      "xml",
      "yaml",
      -- "toml",
    },
  },

  -- Per-filetype configuration
  filetypes = {
    bash = {
      formatters = { "shfmt" },
    },
    css = {
      linters = { "oroshi_css_lint" },
      formatters = { "oroshi_css_fix" },
      configureLinter = cssHelper.configureLinter,
      configureFormatter = cssHelper.configureFormatter,
      formatterTimeout = 10000,
    },
    html = {
      formatters = { "oroshi_html_fix" },
      configureFormatter = htmlHelper.configureFormatter,
      formatterTimeout = 10000,
    },
    javascript = {
      linters = { "oroshi_js_lint" },
      formatters = { "oroshi_js_fix" },
      configureLinter = javascriptHelper.configureLinter,
      configureFormatter = javascriptHelper.configureFormatter,
      formatterTimeout = 10000,
    },
    javascriptreact = {
      linters = { "oroshi_js_lint" },
      formatters = { "oroshi_js_fix" },
      configureLinter = javascriptHelper.configureLinter,
      configureFormatter = javascriptHelper.configureFormatter,
      formatterTimeout = 10000,
    },
    json = {
      linters = { "oroshi_json_lint" },
      formatters = { "oroshi_json_fix" },
      configureLinter = jsonHelper.configureLinter,
      configureFormatter = jsonHelper.configureFormatter,
      formatterTimeout = 10000,
    },
    lua = {
      lsp = { "lua_ls" },
      configureLsp = luaHelper.configureLsp,
      formatters = { "stylua" },
      configureFormatter = luaHelper.configureFormatter,
    },
    python = {
      linters = { "oroshi_python_lint" },
      formatters = { "oroshi_python_fix" },
      configureLinter = pythonHelper.configureLinter,
      configureFormatter = pythonHelper.configureFormatter,
    },
    sh = {
      formatters = { "shfmt" },
    },
    toml = {
      -- Note 1: Taplo as an LSP server identifies itself as "Even Better TOML".

      -- Note 2: We have a toml-lint binary outside of nvim that produces an
      -- output similar to what the LSP server + linter does here, in mostly
      -- human-readable format. This script could be improved to provide a
      -- machine-readable JSON output so we could use it in nvim, but this
      -- isn't done yet.
      lsp = { "taplo" },
      formatters = { "taplo" },
      linters = { "oroshi_fly_lint" },
      configureLinter = tomlHelper.configureLinter,
    },
    typescript = {
      linters = { "oroshi_js_lint" },
      formatters = { "oroshi_js_fix" },
      configureLinter = javascriptHelper.configureLinter,
      configureFormatter = javascriptHelper.configureFormatter,
      formatterTimeout = 10000,
    },
    typescriptreact = {
      linters = { "oroshi_js_lint" },
      formatters = { "oroshi_js_fix" },
      configureLinter = javascriptHelper.configureLinter,
      configureFormatter = javascriptHelper.configureFormatter,
      formatterTimeout = 10000,
    },
    vue = {
      linters = { "oroshi_js_lint" },
      formatters = { "oroshi_js_fix" },
      configureLinter = javascriptHelper.configureLinter,
      configureFormatter = javascriptHelper.configureFormatter,
      formatterTimeout = 10000,
    },
    zsh = {
      formatters = { "shfmt_zsh" },
      linters = { "zshlint" },
      configureFormatter = zshHelper.configureFormatter,
      configureLinter = zshHelper.configureLinter,
    },
  },
}

return {
  -- Dependencies: Mason
  -- https://github.com/mason-org/mason.nvim
  -- Install all required dependencies, like LSP servers, linters or formatters
  {
    "mason-org/mason.nvim",
    config = function()
      require("mason").setup()

      helper.synchronizeMasonDependencies(config.dependencies.mason)

      -- Configure various parts of the UI that depends on those dependencies
      helperDiagline.init()
      helperStatusline.init()
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
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects", -- Allow vit / vat
    },
    config = function()
      local treesitterConfig = require("nvim-treesitter.configs")

      -- Synchronize parsers: uninstall unused ones, install via ensure_installed
      helper.synchronizeTreesitterParsers(config.dependencies.treesitter)

      treesitterConfig.setup({
        ensure_installed = config.dependencies.treesitter,

        highlight = {
          enable = true,
          additional_vim_regex_highlighting = true,
        },
        indent = {
          enable = true,
        },
        -- Select node with vv (then expand with CTRL-K / shrink with CTRL-J)
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "vv", -- Select node
            node_incremental = "<C-K>", -- Expand to parent node
            node_decremental = "⒥", -- Shrink to child node
            scope_incremental = false,
          },
        },
      })
    end,
  },

  -- LSP
  -- Installs LSP servers and configure them.
  -- https://github.com/mason-org/mason-lspconfig.nvim
  -- https://github.com/neovim/nvim-lspconfig
  --
  -- LSP servers are complex dynamic systems that understand code as we type.
  -- They can be used for auto-completion, type definition, linting,
  -- refactoring, etc
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      helper.configureLspServers(config.filetypes)
    end,
  },

  -- Linters: nvim-lint
  -- https://github.com/mfussenegger/nvim-lint
  -- Spawns linter asynchronously and display results
  -- This should be used only when LSP Diagnostics are not enough
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      helper.configureLinters(config.filetypes)

      local lint = require("lint")
      F.autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, function()
        lint.try_lint()
      end)
    end,
  },

  -- Formatters: conform
  -- https://github.com/stevearc/conform.nvim
  -- Format code automatically
  {
    "stevearc/conform.nvim",
    dependencies = {
      "mason-org/mason.nvim",
    },
    config = function()
      helper.configureFormatters(config.filetypes)
    end,
  },

  -- mini.trailspace
  -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-trailspace.md
  -- Remove trailing spaces on save
  {
    "echasnovski/mini.trailspace",
    version = "*",
    config = function()
      local trailspace = require("mini.trailspace")
      F.autocmd("BufWritePre", function()
        trailspace.trim() -- Remove trailing spaces
        trailspace.trim_last_lines() -- Remove trailing lines
      end)
    end,
  },
}
