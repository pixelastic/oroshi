augroup ftdetect_ruby
  autocmd!
  " awesome_print config file
  autocmd BufRead,BufNewFile *.aprc set filetype=ruby
  autocmd BufRead,BufNewFile Guardfile* set filetype=ruby
augroup END

