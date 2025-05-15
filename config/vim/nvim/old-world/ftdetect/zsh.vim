" Assume that all autoload and completion methods are written in zsh
augroup ftdetect_zsh_functions
  autocmd!
  autocmd BufRead,BufNewFile *config/term/zsh/functions/autoload/* set ft=zsh
  autocmd BufRead,BufNewFile *config/term/zsh/completion/functions/* set ft=zsh
augroup END
