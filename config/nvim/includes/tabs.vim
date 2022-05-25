" TABS {{{
" Do not limit the number of tabs to open when launching vim
set tabpagemax=1000
" Open file in new tab with ,t
nnoremap <Leader>t :tabe<Space>

" [CTRL-H] Previous tab
nnoremap <C-H> gT
inoremap <C-H> <Esc>gT
cnoremap <C-H> <C-C>gT
" [CTRL-L] Next tab
nnoremap <C-L> gt
inoremap <C-L> <Esc>gt
cnoremap <C-L> <C-C>gt

" [CTRL-LEFT] Move tab to the left
nnoremap <silent> <C-Left> :-tabmove<CR>
inoremap <silent> <C-Left> <Esc>:-tabmove<CR>
" [CTRL-RIGHT] Move tab to the right
nnoremap <silent> <C-Right> :+tabmove<CR>
inoremap <silent> <C-Right> <Esc>:+tabmove<CR>
" }}}
