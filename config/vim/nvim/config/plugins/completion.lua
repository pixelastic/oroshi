-- -- Completion
-- -- Suggest stuff as I type
return {
  -- Cmp
  -- https://github.com/hrsh7th/nvim-cmp
  -- Completion system
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lua", -- nvim-specific lua commands
      "hrsh7th/cmp-buffer", -- text in buffer
      "hrsh7th/cmp-path", -- paths on disk
      -- {
      --   "L3MON4D3/LuaSnip",
      --   -- follow latest release.
      --   version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
      --   -- install jsregexp (optional!).
      --   build = "make install_jsregexp",
      -- },
      -- "saadparwaiz1/cmp_luasnip", -- for autocompletion
      -- "rafamadriz/friendly-snippets", -- useful snippets
      -- "onsails/lspkind.nvim", -- vs-code like pictograms
    },
    config = function()
      local cmp = require("cmp")
      local context = require('cmp.config.context')

      local function completeOrNext()
        if cmp.visible() then
          cmp.select_next_item()
        else
          cmp.complete()
        end
      end

      -- toggleMenu: Display a visible menu
      local function toggleMenu()
        -- Close if already openeds
        if cmp.visible() then
          cmp.close()
          F.hideCompletionWildmenu()
          return
        end

        -- Open, as a real menu
        F.showCompletionWildmenu()
        cmp.complete({
          config = {
            view = {
              entries = "custom"
            }
          }
        })
      end

      -- local function selectCompletion()
      --   cmp.mapping.confirm({ select = false }),
      -- end


      -- Disable completion based on context
      local function disableBasedOnContext()
        local blockerTypes = { "comment", "zshComment", "string", "number" }

        -- Check all blockers to see if they are part of the current highlights
        local currentTypes = F.getHighlightGroups()
        for _, typeName in ipairs(blockerTypes) do
          local treesitterName = typeName:lower() -- string
          if F.includes(currentTypes, treesitterName) then
            return false
          end

          local syntaxName = typeName:gsub('^%l', string.upper) -- String
          if F.includes(currentTypes, syntaxName) then
            return false
          end
        end

        -- If none found, we can enable completion
        return true
      end

      cmp.setup({
        enabled = disableBasedOnContext,
        keyword_length = 3,
        experimental = {
          ghost_text = {
            hl_group = 'CmpGhostText'
          }
        },
        view = {
          entries = "wildmenu",
        },
        mapping = {
          ["<Tab>"] = completeOrNext,
          ["<C-Space>"] = toggleMenu,
          ["<Down>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          ["<Up>"] = cmp.mapping.select_prev_item(),
          ["<C-c>"] = cmp.mapping.abort(),
          ["<C-d>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
        },
        sources = cmp.config.sources({
          { name = 'nvim_lua' }, -- cmp-nvim-lua
          { name = "path" }, -- cmp-path
          { name = "buffer" }, -- cmp-buffer
          -- { name = "luasnip" }, -- snippets
        }),
        -- snippet = { -- configure how nvim-cmp interacts with snippet engine
        --   expand = function(args)
        --     luasnip.lsp_expand(args.body)
        --   end,
        -- },

        -- configure lspkind for vs-code like pictograms in completion menu
        -- formatting = {
        --   format = lspkind.cmp_format({
        --     maxwidth = 50,
        --     ellipsis_char = "...",
        --   }),
        -- },
      })
    end,
  },

  -- Treesitter
  -- https://github.com/nvim-treesitter/nvim-treesitter
  -- Highlight, indent, folding, AST
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
