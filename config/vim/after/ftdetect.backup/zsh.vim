" ZSH
" We consider all files in zsh/completion to be zsh
augroup ftdetect_zsh
  autocmd!
  autocmd BufRead,BufNewFile *zsh/completion/* set filetype=zsh
augroup END
