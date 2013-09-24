" Note: We need to set the filetype partly as sass so the css-color plugin
" correctly highlights color, but also as scss so the various SCSS syntactic
" sugar are correctly highligted.
au BufRead,BufNewFile *.scss	set filetype=sass.scss
