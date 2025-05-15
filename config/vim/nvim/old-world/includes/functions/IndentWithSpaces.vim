function! IndentWithSpaces()
  normal! mz
  " Replace all tabs used for indentation with the same number of spaces
  silent! execute '%s/\v^\s+/\=substitute(submatch(0),"\t",repeat(" ", &tabstop),"g")'
  " Remove any leftover
  silent! execute '%s/\v^+/\=repeat(" ",len(submatch(0))-(len(submatch(0))%&tabstop))'
  nohl
  normal! `z
endfunction
command! IndentWithSpaces call IndentWithSpaces()
