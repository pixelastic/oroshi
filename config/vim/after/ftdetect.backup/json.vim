" JSON
augroup ftdetect_json
  autocmd!
  autocmd BufRead,BufNewFile .eslintrc set filetype=json
  autocmd BufRead,BufNewFile .babelrc set filetype=json
augroup END

