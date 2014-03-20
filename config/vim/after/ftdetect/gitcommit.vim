" GITCOMMIT
" Vim < 7.4 seems to not recognize gitcommit files
au BufRead,BufNewFile *COMMIT_EDITMSG set filetype=gitcommit
