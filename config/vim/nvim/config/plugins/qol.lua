-- QoL
-- Quality of life improvements
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

      vim.notify = notify
    end
  },
  -- ScrollEOF
  -- https://github.com/Aasim-A/scrollEOF.nvim
  -- Keep current line always in the middle of screen
  {
    'Aasim-A/scrollEOF.nvim',
    event = { 'CursorMoved', 'WinScrolled' },
  }
}
