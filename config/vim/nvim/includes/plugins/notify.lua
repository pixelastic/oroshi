return {
  -- https://github.com/rcarriga/nvim-notify
  -- Display messages in a floating notification window
  -- enable = false,
  "rcarriga/nvim-notify",
  config = function()
    local notify = require('notify')
    notify.setup({
      background_colour = "#FFFFFF"
    })

    vim.notify = notify
  end
}
