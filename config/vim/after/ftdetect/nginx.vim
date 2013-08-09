" NGINX
" Make a broader nginx detection, to allow files in dotfile repo
au BufRead,BufNewFile */nginx/*.conf set ft=nginx

