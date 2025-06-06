-- -- QoL
-- -- Quality of life improvements
return {
  -- Notify
  -- https://github.com/rcarriga/nvim-notify
  -- Display messages in a floating notification window
  {
    "rcarriga/nvim-notify",
    config = function()
      local notify = require('notify')
      notify.setup({
        minimum_width = 30,
        render = 'wrapped-compact',
        stages = "static"
      })

      -- vim.notify = notify
    end
  },
  -- Noice
  -- https://github.com/folke/noice.nvim
  -- Replaces the UI of messages, CmdLine and popupmenu
  -- Note: I couldn't get show_pos() to work with that, it was displayed in a
  -- popup window and disappeared
  -- {
  --   "folke/noice.nvim",
  --   event = "VeryLazy",
  --   dependencies = {
  --     "MunifTanjim/nui.nvim",
  --     "rcarriga/nvim-notify",
  --   },
  --   config = function()
  --     local noice = require('noice')
  --     noice.setup({
  --       presets = {
  --         -- bottom_search = false, -- use a classic bottom cmdline for search
  --         -- command_palette = true, -- position the cmdline and popupmenu together
  --         -- long_message_to_split = true, -- long messages will be sent to a split
  --         -- inc_rename = false, -- enables an input dialog for inc-rename.nvim
  --         -- lsp_doc_border = false, -- add a border to hover docs and signature help
  --       },
  --
  --     })
  --   end,
  -- },
  -- ScrollEOF
  -- https://github.com/Aasim-A/scrollEOF.nvim
  -- Keep current line always in the middle of screen
  {
    'Aasim-A/scrollEOF.nvim',
    event = { 'CursorMoved', 'WinScrolled' },
  }
}
