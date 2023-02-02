function! RunCurrentFile()
  execute ':!%:p'
endfunction
command! Run call RunCurrentFile()
