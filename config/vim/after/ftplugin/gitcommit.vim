" GITCOMMIT
" Saves commit with Ctrl+S
nnoremap <buffer> <C-S> :x<CR>
inoremap <buffer> <C-S> <Esc>:x<CR>
" Discard commit with Ctrl+D
nnoremap <buffer> <C-D> :cq!<CR>
inoremap <buffer> <C-D> <Esc>:cq!<CR>

" Move cursor at top of file
au BufEnter <buffer> call GitCommitOnBufEnter()
function! GitCommitOnBufEnter() 
	normal gg
endfunction
