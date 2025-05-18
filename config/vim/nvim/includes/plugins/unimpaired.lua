return {
  'tummetott/unimpaired.nvim',
  event = 'VeryLazy',
  opts = {
    default_keymaps = false,
    keymaps = {
      blank_above = { mapping = '<S-CR>' }, -- Add line above
      blank_below = { mapping = '<CR>' },   -- Add line below
      exchange_above = { mapping = '-' },    -- Move current line up
      exchange_section_above = { mapping = '-' }, -- Move selection up
      exchange_below = { mapping = '_' }, -- Move current line down
      exchange_section_below = { mapping = '_' }, -- Move current line down
      toggle_wrap = { mapping = '<F9>' }, -- Toggle Wrap
    },
  },
}
