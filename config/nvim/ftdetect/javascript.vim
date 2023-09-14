" Auto-set ft=javascript for zx files
function! s:Ftdetect_zx()
  if JavaScriptIsZx()
    set ft=javascript
  endif
endfun

autocmd BufNewFile,BufRead * call s:Ftdetect_zx()
