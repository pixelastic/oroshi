" Sort selection (using version sort)
vnoremap ss :!sort --version-sort<CR>
vnoremap sS :!sort --version-sort --reverse<CR>

" Sort lines by line length
vnoremap sl :!sort-by-length<CR>

" Remove duplicate lines
vnoremap su :sort u<CR>

" Randomize lines
vnoremap sr :!shuf<CR>

" Number lines
vnoremap sn :!cat -n<CR>
