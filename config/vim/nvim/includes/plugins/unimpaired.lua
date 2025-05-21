return {
  -- https://github.com/tummetott/unimpaired.nvim
  -- Move lines around, or toggle features
  -- enabled = false,
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

        exchange_above = { mapping = '-' },    -- Move current line up
        exchange_below = { mapping = '_' }, -- Move current line down

        toggle_wrap = { mapping = '<F9>' }, -- Toggle Wrap
        toggle_hlsearch = { mapping = ',<Space>' }, -- Toggle search highlight
      },
    })

    -- Move selection up and down
    -- '< and '> marks are only updated when leaving visual mode
    -- So, we need to leave and quickly come back in visual mode to be able to
    -- use '< and '> in the mapping
    local function refreshSelectionBounds()
      vim.api.nvim_command('normal ') -- <Esc> to leave visual mode
      vim.cmd('normal gv') -- Reselecting previous selection
    end
    local function moveSelectionUp()
      refreshSelectionBounds()
      vim.cmd("silent! '<,'>move '<--")
      vim.cmd('normal gv')
    end
    local function moveSelectionDown()
      refreshSelectionBounds()
      vim.cmd("silent! '<,'>move '>+")
      vim.cmd('normal gv')
    end
    vmap('-', moveSelectionUp, 'move up')
    vmap('_', moveSelectionDown, 'move up')
  end
}
