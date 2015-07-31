" TXT
" Auto-wrap text
setlocal formatoptions+=t
" Allow folding with marker
setlocal foldmethod=marker
setlocal commentstring=\ %s
" Make txt files more portable
if expand('%:e') ==? 'txt'
  silent call ConvertLineEndingsToUnix()
  silent call ConvertWindowsCharacters()
endif
" Update filetype when adding a shebang
augroup ft_txt_update_filetype
  au!
  au BufWritePost <buffer> filetype detect
augroup END

