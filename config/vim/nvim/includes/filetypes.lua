-- ftdetect:
-- Helper function to define a custom overide of filetype
function ftdetect(pattern, callback)
  vim.api.nvim_create_autocmd(
    { 'BufRead', 'BufNewFile' }, 
    { pattern = pattern, callback = callback }
  )
end

-- xkb
ftdetect(
  "*config/keybindings/xkb/xkbmaprc.conf", 
  function()
    vim.bo.filetype = "c"
    vim.bo.syntax = "xkb"
    vim.bo.commentstring = "// %s"
  end
)

-- zsh
ftdetect(
  "*config/term/zsh/functions/autoload/*", 
  function()
    vim.bo.filetype = "zsh"
  end
)
