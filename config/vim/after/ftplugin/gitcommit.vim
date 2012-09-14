" GITCOMMIT
" Saves commit with Ctrl+S
nnoremap <buffer> <C-S> :x<CR>
inoremap <buffer> <C-S> <Esc>:x<CR>
" Discard commit with Ctrl+D
nnoremap <buffer> <C-D> :q!<CR>
inoremap <buffer> <C-D> <Esc>:q!<CR>
" Start in insert mode to type the message
" au BufEnter <buffer> call feedkeys('ggi', 't')
