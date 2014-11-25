" GITCOMMIT
" Keybindings {{{
" Saves commit with Ctrl+S
nnoremap <buffer> <C-S> :x<CR>
inoremap <buffer> <C-S> <Esc>:x<CR>
" Discard commit with Ctrl+D
nnoremap <buffer> <C-D> :cq!<CR>
inoremap <buffer> <C-D> <Esc>:cq!<CR>
" }}}

" Initial loading {{{
augroup gitcommit_BufEnter
  autocmd!
  au BufEnter <buffer> call GitCommitOnBufEnter()
augroup END
function! GitCommitOnBufEnter() 
  let @x='# Possible types : chore, docs, feat, fix, perf, refactor, style, test'
  normal 1gg
  put x
  normal gg
endfunction
" }}}
