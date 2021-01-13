" Shell
" .envrc files should be considered shell files
augroup ftdetect_shell
  autocmd!
  autocmd BufRead,BufNewFile *.envrc set filetype=sh
augroup END
