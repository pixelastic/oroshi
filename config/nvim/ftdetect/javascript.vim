function! s:Ftdetect_zx()
    if getline(1) == '#!/usr/bin/env zx'
        set ft=javascript
    endif
endfun

autocmd BufNewFile,BufRead * call s:Ftdetect_zx()
