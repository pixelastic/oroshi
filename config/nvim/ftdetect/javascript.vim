" Auto-set ft=javascript for zx files
function! s:Ftdetect_zx()
  if JavaScriptIsZx()
    set filetype=javascript
  endif
endfun

augroup ft_zx
  autocmd!
  autocmd BufNewFile,BufRead * call s:Ftdetect_zx()
augroup END
