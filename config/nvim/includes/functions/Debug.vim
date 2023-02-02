function! Debug(txt)
  " Display a var in the status line, for debug purposes
  let b:o_debug = a:txt
endfunction
command! -nargs=1 Debug call Debug(<q-args>)
