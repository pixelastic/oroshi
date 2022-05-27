" F6: Current file:line
function! CopyFileAndLine()
  let @+ = expand('%:p').':'.line('.')
endfunction
inoremap <silent> <F6> <Esc>:call CopyFileAndLine()<CR>
nnoremap <silent> <F6> :call CopyFileAndLine()<CR>
