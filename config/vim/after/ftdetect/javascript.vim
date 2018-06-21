" JavaScript files
augroup ftdetect_javascript
  autocmd!
  " Consider Jest snapshots as JavaScript files
  autocmd BufRead,BufNewFile *.test.js.snap set filetype=javascript
augroup END

