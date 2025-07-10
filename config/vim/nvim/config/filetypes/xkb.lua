-- xkb
F.onRead(
  "*config/keybindings/xkb/xkbmaprc.conf",
  function()
    vim.bo.filetype      = "c"
    vim.bo.syntax        = "xkb"
    vim.bo.commentstring = "// %s"
  end
)
