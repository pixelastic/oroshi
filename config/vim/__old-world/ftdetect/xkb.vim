" There is no xkb syntax plugin for vim (AFAICT), so this attemps at setting
" some default sane values for syntax and comments.
augroup ftdetect_xkb
  autocmd!
  autocmd BufRead,BufNewFile *config/keybindings/xkb/xkbmaprc.conf set ft=c syntax=xkb commentstring=//\ %s
augroup END
