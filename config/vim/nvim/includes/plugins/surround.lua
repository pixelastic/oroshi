return {
  -- https://github.com/kylechui/nvim-surround
  -- LUA version of vim-surround. Its main advantage is that it can keep the
  -- cursor at the exact position it was before, rather than jump to the
  -- beginning
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
