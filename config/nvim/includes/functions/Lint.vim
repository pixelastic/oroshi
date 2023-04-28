" Cleanup the file
" Neoformat will reformat the file
" Ale will try to fix linting issues
" Ale will also display linting issues
"
" Neoformat formatting and Ale fixing might overlap
" So better to use the same tool for both, or have tools with compatible rules
function! Lint()
  silent Neoformat
  ALEFix
  ALELint
endfunction
