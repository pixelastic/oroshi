" FUGITIVE
" Keyboard hotkeys that I already use in my terminal for a quick access to git
" methods.
" [f]iles {{{
" Add current file to index
nnoremap <silent> vfa :Gwrite<CR>
" Remove current file from index
nnoremap <silent> vfu :Git unstage %<CR><CR>
" }}}
" [c]ommits {{{
" Commit
nnoremap <silent> vcc :Gcommit<CR>
" Commit all
nnoremap <silent> vcca :Git add .<CR>:Gcommit<CR>
" }}}
