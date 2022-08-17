" VISUAL WRAPPING
" By default, longer lines extend beyond the limit, and don't wrap
set nowrap
" Lines will visually wrap at words (not in the middle of them)
set linebreak
" A ↪ will be displayed to indicate the continuation of a previous line
let &showbreak='↪ '

nnoremap <silent> <F9> :set wrap!<CR>
vnoremap <silent> <F9> :set wrap!<CR>
inoremap <silent> <F9> <Esc>:set wrap!<CR>li
