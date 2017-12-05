" CSS files
augroup ftdetect_css
  autocmd!
  " postCSS emulates many of the features of CSS, but we're not using it in every
  " project yet.
  " We have to put this line here and not in ftplugin/css.vim because otherwise
  " vim will set the syntax to css by default
  autocmd BufRead,BufNewFile */tachyons-algolia/*.css set syntax=scss
augroup END

