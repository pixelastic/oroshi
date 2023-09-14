" HJKL {{{
" I use hjkl to move around, visually, on the grid
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk

" [CTRL-H] Previous tab
nnoremap <C-H> gT
inoremap <C-H> <Esc>gT
cnoremap <C-H> <C-C>gT
" [CTRL-L] Next tab
nnoremap <C-L> gt
inoremap <C-L> <Esc>gt
cnoremap <C-L> <C-C>gt

" [CTRL-Shift-H] Move tab to the left
nnoremap <silent> Ⓗ :-tabmove<CR>
inoremap <silent> Ⓗ <Esc>:-tabmove<CR>
" [CTRL-Shift-L] Move tab to the right
nnoremap <silent> Ⓛ :+tabmove<CR>
inoremap <silent> Ⓛ <Esc>:+tabmove<CR>

" [CTRL-J] Next autocompletion
cnoremap <C-J> <C-N>

" [CTRL-K] Previous autocompletion
cnoremap <C-K> <C-P>

" }}}
"
"
