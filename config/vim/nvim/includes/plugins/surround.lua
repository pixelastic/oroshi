return {
  -- https://github.com/kylechui/nvim-surround
  -- Change surrounding quotes or parentheses
  -- enabled = false,
  "kylechui/nvim-surround",
  version = "3.1.1",
  event = "VeryLazy",
  config = function()
    local surround = require("nvim-surround")
    surround.setup({
      move_cursor = 'sticky'
    })
  end
}
