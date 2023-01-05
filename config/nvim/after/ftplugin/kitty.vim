
" We enable coloring of hexadecimal codes in kitty
augroup ftplugin_kitty
  autocmd!
  autocmd BufEnter <buffer> syn include ~/.config/nvim/plugins/vim-coloresque/after/syntax/css/vim-coloresque.vim
augroup END
