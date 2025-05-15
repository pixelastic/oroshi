function! StrTrim(txt)
  " Trim a string by removing starting and trailing whitespaces
  return substitute(a:txt, '^\n*\s*\(.\{-}\)\n*\s*$', '\1', '')
endfunction
