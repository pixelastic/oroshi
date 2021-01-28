" VIM HELP
" We only define the function if non-existing, this prevent trying to create it
" when in use
if !exists("*JumpToVimDocumentation")
  function! JumpToVimDocumentation()
    execute 'h '.expand('<cword>')
  endfunction
endif
nnoremap <silent> <F1> :call JumpToVimDocumentation()<CR>
