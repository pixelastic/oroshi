return {
  "rcarriga/nvim-notify",
  config = function()
    local notify = require('notify')
    notify.setup({
      background_colour = "#FFFFFF"
    })

    vim.notify = notify
    vim.print = notify
    vim.error = notify

    nmap('N', function()
     notify("My super important message")
    end, 'kjkjk')
  end
}
