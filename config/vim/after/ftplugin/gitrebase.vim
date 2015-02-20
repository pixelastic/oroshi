" GITREBASE

" Change command {{{
function! GitRebaseChangeLineCommand(type)
  normal! mz
  execute "normal! ^ciw" . a:type
  normal! `z
endfunction
nnoremap <buffer> <silent> p :call GitRebaseChangeLineCommand('pick')<CR>
nnoremap <buffer> <silent> r :call GitRebaseChangeLineCommand('reword')<CR>
nnoremap <buffer> <silent> e :call GitRebaseChangeLineCommand('edit')<CR>
nnoremap <buffer> <silent> s :call GitRebaseChangeLineCommand('squash')<CR>
nnoremap <buffer> <silent> f :call GitRebaseChangeLineCommand('fixup')<CR>
" }}}
" Abort
nnoremap <buffer> <C-D> ggdG:x!<CR>




