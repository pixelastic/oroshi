" Sort selection (using version sort)
vnoremap s :!sort --version-sort<CR>
vnoremap S :!sort --version-sort --reverse<CR>

" Sort lines by line length
vnoremap L :!sort-by-length<CR>

" Remove duplicate lines
vnoremap u :sort u<CR>

" Randomize lines
vnoremap R :!shuf<CR>

" Number lines
vnoremap n :!cat -n<CR>
