" HJKL {{{
" I use hjkl to move around, visually, on the grid
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk

" In autocomplete mode, we hijack them to act as up and down

" Autocomplete in insert mode
inoremap <expr> j pumvisible() ? "\<C-N>" : "j"
inoremap <expr> k pumvisible() ? "\<C-P>" : "k"
"
" Autocomplete in command mode (opening a file for example)
cnoremap <expr> j pumvisible() ? "\<C-N>" : "j"
cnoremap <expr> k pumvisible() ? "\<C-P>" : "k"

" }}}
