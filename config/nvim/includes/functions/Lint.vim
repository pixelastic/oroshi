" Cleanup the file
" Neoformat will reformat the file
" Ale will try to fix linting issues
" Ale will also display linting issues
"
" Neoformat formatting and Ale fixing might overlap
" So better to use the same tool for both, or have tools with compatible rules
function! Lint()
  " Note: Neoformat should be called before ALE. Neoformat is synchronous, so it
  " should not be called while ALE is trying to fix the file, or it risks
  " changing the file before ALE has had time to finish.
  " silent Neoformat

  ALEFix
  ALELint
endfunction
