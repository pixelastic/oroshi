" TEXT
" Make text the default filetype if nothing else is found
augroup ftdetect_txt
  autocmd!
  autocmd BufEnter * setfiletype text
augroup END
