" CSS files
augroup ftdetect_css
  autocmd!
  " Use scss syntax as its closer to what postCSS can allow
  autocmd BufRead,BufNewFile *.css set syntax=scss
augroup END

