function! ConvertLineEndingsToUnix()
  if &modifiable==0 || expand('%') ==# '' || !filereadable(expand('%'))
    return
  endif
  update
  " Wrapping in a condition prevents an infinite loop of update/save/trigger
  if &fileformat !~# 'dos'
    edit ++fileformat=dos
  endif
  execute '%s///ge'
  setlocal fileformat=unix
  write
endfunction
command! ConvertLineEndingsToUnix call ConvertLineEndingsToUnix()
