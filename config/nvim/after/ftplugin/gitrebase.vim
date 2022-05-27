" GITREBASE

function! GitRebaseChangeLineCommand(type)
  execute "normal! ^ciw" . a:type
  normal gj
endfunction
nnoremap <buffer> <silent> p :call GitRebaseChangeLineCommand('pick')<CR>
nnoremap <buffer> <silent> r :call GitRebaseChangeLineCommand('reword')<CR>
nnoremap <buffer> <silent> e :call GitRebaseChangeLineCommand('edit')<CR>
nnoremap <buffer> <silent> s :call GitRebaseChangeLineCommand('squash')<CR>
nnoremap <buffer> <silent> f :call GitRebaseChangeLineCommand('fixup')<CR>

vnoremap <buffer> p :normal ^ciwpick<CR>
vnoremap <buffer> r :normal ^ciwreword<CR>
vnoremap <buffer> e :normal ^ciwedit<CR>
vnoremap <buffer> s :normal ^ciwsquash<CR>
vnoremap <buffer> f :normal ^ciwfixup<CR>

