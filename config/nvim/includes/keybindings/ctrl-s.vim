" [CTRL-S] saves the file, as in most apps
" Note: We wrap the function definition in an exists() because defining the
" function with function! like we usually do fails here because it is attempting
" to redefine itself while being in use
if !exists("*SaveFile")
  function SaveFile()
    if &diff | only | endif
    write!
  endfunction
endif
nnoremap <silent> <C-S> :call SaveFile()<CR>
inoremap <silent> <C-S> <Esc>:call SaveFile()<CR>
