function! IndentLevel(lnum)
  return indent(a:lnum) / &shiftwidth
endfunction
