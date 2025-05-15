function! StrLength(txt)
  " Return the number of chars in a string.
  " Note: This is different from strlen() as strlen() returns the number of
  " bytes, which is very different for utf-8 encoding.
  return strlen(substitute(a:txt, '.', 'x', 'g'))
endfunction " }}}
