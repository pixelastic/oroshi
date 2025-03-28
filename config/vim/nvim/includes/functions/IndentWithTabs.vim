function! IndentWithTabs()
  normal! mz
  " Indent first with spaces, then convert to tabs
  silent! call IndentWithSpaces()
  silent! execute '%s_\v^ +_\=repeat("\t",len(submatch(0))/&tabstop)'
  nohl
  normal! `z
endfunction
command! IndentWithTabs call IndentWithTabs()
