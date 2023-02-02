function! RemoveTrailingSpaces()
  normal! mz
  silent! %s/\s\+$//g
  nohl
  normal! `z
endfunction
command! RemoveTrailingSpaces call RemoveTrailingSpaces()
