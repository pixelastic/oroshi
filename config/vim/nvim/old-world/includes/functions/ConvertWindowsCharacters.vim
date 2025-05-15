function! ConvertWindowsCharacters()
  " Note: To type a special char like <92> in vim, press <C-V>x92
  normal! mz
  silent! %s//'/
  silent! %s//"/
  silent! %s//"/
  silent! %s//.../
  nohl
  normal!`z
endfunction
command! ConvertWindowsCharacters call ConvertWindowsCharacters()
