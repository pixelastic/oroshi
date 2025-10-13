local helperDiagline = O_require("oroshi/plugins/helpers/diagline")
local helperStatusline = O_require("oroshi/plugins/helpers/statusline")
local helper = O_require("oroshi/plugins/helpers/code-quality")

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
      "typescript",
      "tsx",
      "json",
      "jsonc",
      "markdown",
      "markdown_inline",
      "nginx",
      "pug",
      "python",
      "regex",
      "robots",
      "ruby",
      "ssh_config",
      -- "toml",
      "xml",
      "yaml",
    },
  },

  -- Per-filetype configuration
  filetypes = {
    bash = {
      formatters = { "shfmt" },
    },
    javascript = {
      linters = { "oroshi_js_lint" },
      formatters = { "oroshi_js_fix" },
      configureLinter = function(lint)
        local javascriptHelper = O_require("oroshi/plugins/helpers/filetypes/javascript")
        lint.linters.oroshi_js_lint = {
          cmd = "js-lint",
          stdin = false,
          args = { "--json" },
          ignore_exitcode = true,
          parser = javascriptHelper.lintParser,
        }
      end,
      configureFormatter = function(conform)
        conform.formatters.oroshi_js_fix = {
          command = "js-fix",
          stdin = true,
          args = { "--filepath", "$FILENAME" },
          exit_codes = { 0, 1 }, -- Do not fail on unfixable errors
          timeout_ms = 5000, -- JS/TS can be slow...
        }
      end,
    },
    typescript = {
      linters = { "oroshi_js_lint" },
      formatters = { "oroshi_js_fix" },
    },
    typescriptreact = {
      linters = { "oroshi_js_lint" },
      formatters = { "oroshi_js_fix" },
    },
    json = {
      formatters = { "prettier" },
    },
    lua = {
      lsp = { "lua_ls" },
      configureLsp = function()
        helper.configureLspServer("lua_ls", {
          on_init = function(client)
            local config = {
              runtime = { version = "LuaJIT" },
              workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
            }
            client.config.settings.Lua = F.merge(client.config.settings.Lua or {}, config)
          end,
        })
      end,
      formatters = { "stylua" },
      configureFormatter = function(conform)
        conform.formatters.stylua = {
          prepend_args = {
            "--indent-type",
            "Spaces",
            "--indent-width",
            vim.o.shiftwidth,
          },
        }
      end,
    },
    sh = {
      formatters = { "shfmt" },
    },
    toml = {
      lsp = { "taplo" },
      formatters = { "taplo" },
      linters = { "flylint" },
      configureLinter = function(lint)
        -- Configure flylint for Fly.io specific errors
        lint.linters.flylint = {
          cmd = "flylint",
          stdin = false, -- Reading from filepath
          ignore_exitcode = true, -- Do not fail on exit 1
          parser = require("lint.parser").from_errorformat("%f:%l:%c:%t%*[^:]:%m", {
            warning = "warning",
            error = "error",
          }),
        }
      end,
    },
    zsh = {
      formatters = { "shfmt_zsh" },
      linters = { "zshlint" },
      configureFormatter = function(conform)
        conform.formatters.shfmt_zsh = {
          command = "shfmt",
          args = { "-i", vim.o.shiftwidth },
          exit_codes = { 0, 1 }, -- Fail silently on zsh-specific syntax
        }
      end,
      configureLinter = function(lint)
        local zshHelper = O_require("oroshi/plugins/helpers/filetypes/zsh")
        lint.linters.zshlint = {
          cmd = "zshlint",
          stdin = false,
          ignore_exitcode = true,
          parser = zshHelper.lintParser,
        }
      end,
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
        -- Select node with vv (then expand with CTRL-J / CTRL-K)
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "vv", -- Select node
            node_incremental = "<C-K>", -- Select parent node
            node_decremental = "<C-J>", -- Deselect parent node
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
