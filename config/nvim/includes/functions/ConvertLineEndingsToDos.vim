function! ConvertLineEndingsToDos()
  if &modifiable==0
    return
  endif
  setlocal fileformat=dos
endfunction
command! ConvertLineEndingsToDos call ConvertLineEndingsToDos()
