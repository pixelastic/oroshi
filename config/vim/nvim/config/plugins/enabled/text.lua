-- -- Text
-- -- Better handling of text (selection, closing, moving, etc)
local nmap = F.nmap
local vmap = F.vmap
return {
  -- Autopairs
  -- https://github.com/windwp/nvim-autopairs
  -- Auto close quotes as I type
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    opts = {
      check_ts = true
    }
  },

  -- Surround
  -- https://github.com/kylechui/nvim-surround
  -- Change surrounding quotes or parentheses
  {
    "kylechui/nvim-surround",
    version = "3.1.1",
    event = "VeryLazy",
    config = function()
      local surround = require("nvim-surround")
      surround.setup({
        move_cursor = 'sticky',
        keymaps = {
          change = "cs",
          normal = "ys",
          delete = "ds",

          -- Disable mappings I don't need
          insert = false,
          insert_line = false,
          normal_cur = false,
          normal_line = false,
          normal_cur_line = false,
          visual = false,
          visual_line = false,
          change_line = false
        },
      })
    end
  },

  -- Targets
  -- https://github.com/wellle/targets.vim
  -- Lots of new operators to select elements
  {
    "wellle/targets.vim",
    config = function()
      -- Arguments
      nmap('via', 'vIa', 'Select an argument', { remap = true })
      nmap('cia', 'cIa', 'Change an argument', { remap = true })
      nmap('dia', 'daa', 'Delete an argument', { remap = true })
    end
  },

  -- Unimpaired
  -- https://github.com/tummetott/unimpaired.nvim
  -- Move lines around, or toggle features
  {
    'tummetott/unimpaired.nvim',
    event = 'VeryLazy',
    version = "0.4.0",
    config = function()
      local unimpaired = require('unimpaired')
      unimpaired.setup({
        default_keymaps = false,
        keymaps = {
          blank_above = { mapping = '<S-CR>' }, -- Add line above
          blank_below = { mapping = '<CR>' },   -- Add line below

          exchange_above = { mapping = '-' }, -- Move current line up
          exchange_below = { mapping = '_' }, -- Move current line down

          toggle_wrap     = { mapping = '<F9>' },     -- Toggle Wrap
          toggle_hlsearch = { mapping = ',<Space>' }, -- Toggle search highlight
        },
      })

      local function moveSelectionUp()
        F.ensureVisualSelection()
        vim.cmd("silent! '<,'>move '<--")
        vim.cmd('normal gv')
      end
      local function moveSelectionDown()
        F.ensureVisualSelection()
        vim.cmd("silent! '<,'>move '>+")
        vim.cmd('normal gv')
      end
      vmap('-', moveSelectionUp, 'move up')
      vmap('_', moveSelectionDown, 'move up')
    end
  },



  -- Mini.align
  -- https://github.com/echasnovski/mini.align
  -- Align selection on specific delimiters
  -- Use: Select text, then press "a," and it will be aligned on ,
  { 
    'echasnovski/mini.align', 
    version = '*',
    config = function()
      require('mini.align').setup({
        mappings = {
          start = 'a'
        },
      })
    end
  },
}
