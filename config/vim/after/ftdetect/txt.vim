" TXT
" Make txt the default filetype if nothing else is found
au BufEnter * if &filetype == "" | setlocal filetype=txt | endif
