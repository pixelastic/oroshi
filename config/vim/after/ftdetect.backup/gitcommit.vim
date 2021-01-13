" GITCOMMIT
" Vim < 7.4 seems to not recognize gitcommit files
augroup ftdetect_gitcommit
  autocmd!
  autocmd BufRead,BufNewFile *COMMIT_EDITMSG set filetype=gitcommit
augroup END
