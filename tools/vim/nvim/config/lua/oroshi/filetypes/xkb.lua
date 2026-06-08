local M = {}

M.onInit = function()
  F.onRead("*tools/keybindings/xkb/config/xkbmaprc.conf", function()
    vim.bo.filetype = "c"
    vim.bo.syntax = "xkb"
    vim.bo.commentstring = "// %s"
  end)
end

return M
