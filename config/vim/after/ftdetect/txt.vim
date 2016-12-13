" TXT
" Make txt the default filetype if nothing else is found
augroup ftdetect_txt
  autocmd!
  autocmd BufEnter * if &filetype == "" | setlocal filetype=txt | endif
augroup END
