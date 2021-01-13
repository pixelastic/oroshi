" GITCONFIG
" We consider all files ending with "gitconfig" to be treated as gitconfig files
augroup ftdetect_gitconfig
  autocmd!
  autocmd BufRead,BufNewFile *gitconfig set filetype=gitconfig
augroup END
