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

" [CTRL-Shift-LEFT] Move tab to the left
inoremap <silent> <C-Left> <Esc>:-tabmove<CR>
" [CTRL-Shift-RIGHT] Move tab to the right
nnoremap <silent> <C-Right> :+tabmove<CR>
inoremap <silent> <C-Right> <Esc>:+tabmove<CR>
" }}}
"
"
