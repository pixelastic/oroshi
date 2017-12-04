" CSS files
augroup ftdetect_css
  autocmd!
  " postCSS emulates many of the features of CSS, but we're not using it in every
  " project yet
  autocmd BufRead,BufNewFile */tachyons-algolia/*.css set syntax=scss
  autocmd BufRead,BufNewFile */tachyons-algolia/*.css set commentstring=//\ %s
augroup END

