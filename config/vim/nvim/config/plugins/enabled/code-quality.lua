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
      "json",
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
      formatters = { "prettier" },
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
      configureFormatter = function()
        local conform = require("conform")
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
      formatters = { "taplo" },
    },
    zsh = {
      formatters = { "shfmt_zsh" },
      linters = { "zshlint" },
      configureFormatter = function()
        local conform = require("conform")
        conform.formatters.shfmt_zsh = {
          command = "shfmt",
          args = { "-i", vim.o.shiftwidth },
          exit_codes = { 0, 1 }, -- Fail silently on zsh-specific syntax
        }
      end,
      configureLinter = function()
        local lint = require("lint")
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

      helper.synchronizeDependencies(config.dependencies.mason)

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
      local lspconfig = require("lspconfig")
      local mason_lspconfig = require("mason-lspconfig")

      -- Run all configureLsp functions
      local configureLspFunctions = F.compact(F.map(config.filetypes, "configureLsp"))
      F.each(configureLspFunctions, function(configureLsp)
        configureLsp()
      end)

      -- Setup remaining LSP servers with default config
      local allLspServers = F.uniq(F.flatten(F.compact(F.map(config.filetypes, "lsp"))))
      local lspServersToSetup = F.difference(allLspServers, helper.manuallyConfiguredLspServers)
      F.each(lspServersToSetup, function(lspServer)
        lspconfig[lspServer].setup({})
      end)

      -- Setup mason-lspconfig with automatic server setup DISABLED
      -- We'll manually setup only the servers we want
      mason_lspconfig.setup({
        automatic_installation = false,
        handlers = {
          -- Default handler that does NOTHING
          -- This prevents automatic setup of all installed LSP servers
          function(server_name)
            -- Intentionally empty - we don't want automatic setup
          end,
        },
      })
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
      local lint = require("lint")
      lint.linters = {}
      lint.linters_by_ft = {}

      -- Configure linters based on filetypeConfig
      F.each(config.filetypes, function(config, filetype)
        if not config.linters or F.isEmpty(config.linters) then
          return
        end
        lint.linters_by_ft[filetype] = config.linters
      end)

      -- Run all configureLinter functions
      local configureLinterFunctions = F.compact(F.map(config.filetypes, "configureLinter"))
      F.each(configureLinterFunctions, function(configureLinter)
        configureLinter()
      end)

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
      local conform = require("conform")

      -- Build formatters_by_ft from filetypeConfig
      local formatters_by_ft = {}
      F.each(config.filetypes, function(config, filetype)
        if not config.formatters or F.isEmpty(config.formatters) then
          return
        end
        formatters_by_ft[filetype] = config.formatters
      end)

      conform.setup({
        formatters_by_ft = formatters_by_ft,
        format_on_save = {
          timeout_ms = 500,
        },
      })

      -- Run all configureFormatter functions
      local configureFormatterFunctions = F.compact(F.map(config.filetypes, "configureFormatter"))
      F.each(configureFormatterFunctions, function(configureFormatter)
        configureFormatter(conform)
      end)
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
