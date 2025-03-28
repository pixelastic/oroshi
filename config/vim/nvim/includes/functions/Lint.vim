" Cleanup the file
" Ale will try to fix linting issues
" Ale will also display linting issues
function! Lint()
  ALEFix
  ALELint
endfunction
