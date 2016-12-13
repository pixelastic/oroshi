" *.srt files
augroup ftdetect_srt
  autocmd!
  autocmd BufRead,BufNewFile *.srt set filetype=txt.srt
augroup END

