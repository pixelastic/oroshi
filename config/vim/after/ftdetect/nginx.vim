" NGINX
" Make a broader nginx detection, to allow files in dotfile repo
augroup ftdetect_nginx
  autocmd!
  autocmd BufRead,BufNewFile */nginx/*.conf set ft=nginx
augroup END

