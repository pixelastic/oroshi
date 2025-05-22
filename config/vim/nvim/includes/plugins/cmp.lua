return {
  -- https://github.com/hrsh7th/nvim-cmp
  -- Completion system
  -- enabled = false,
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-buffer", -- source for text in buffer
    "hrsh7th/cmp-path", -- source for file system paths
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

    -- Disable completion based on context
    local function isEnabled()
      -- Disable in comments
      local isInComment = context.in_treesitter_capture("comment")
      local isInString = context.in_treesitter_capture("string")

      return not(isInComment or isInString)
    end

    -- When completing from wildmenu, flash of non focus, need to change the
    -- NormalNC highlight
    -- 


    cmp.setup({
      enabled = isEnabled,
      view = {
        entries = "wildmenu",
      },
      experimental = {
        ghost_text = {
          hl_group = 'CmpGhostText'
        }
      },
      mapping = {
        ["<Tab>"] = completeOrNext,
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        ["<C-c>"] = cmp.mapping.abort(),
        ["<C-d>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
      },
      -- sources for autocompletion
      sources = cmp.config.sources({
        -- { name = "luasnip" }, -- snippets
        { name = "buffer" }, -- text within current buffer
        { name = "path" }, -- file system paths
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
}
