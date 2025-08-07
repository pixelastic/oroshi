-- -- Completion
-- -- Suggest stuff as I type
return {
  -- Cmp
  -- https://github.com/hrsh7th/nvim-cmp
  -- Completion system
  {
    "hrsh7th/nvim-cmp",
    enabled = false,
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
      -- local context = require('cmp.config.context')

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
              entries = "custom",
            },
          },
        })
      end

      -- local function selectCompletion()
      --   cmp.mapping.confirm({ select = false }),
      -- end

      -- Disable completion based on context
      local function disableBasedOnContext()
        -- local blockerTypes = { "comment", "zshComment", "string", "number" }

        -- TODO
        return false
      end

      cmp.setup({
        enabled = disableBasedOnContext,
        keyword_length = 3,
        experimental = {
          ghost_text = {
            hl_group = "CmpGhostText",
          },
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
          { name = "nvim_lsp" },
          { name = "nvim_lua" }, -- Nvim-specific LUA suggestions
          { name = "path" }, -- Complete filepaths
          { name = "buffer" }, -- Complete with words in buffers
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
}
