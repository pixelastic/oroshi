" Assume that all autoload and completion methods are written in zsh
augroup ftdetect_zsh_functions
  autocmd!
  autocmd BufRead,BufNewFile *config/zsh/functions/autoload/* set ft=zsh
  autocmd BufRead,BufNewFile *config/zsh/completion/functions/* set ft=zsh
augroup END
