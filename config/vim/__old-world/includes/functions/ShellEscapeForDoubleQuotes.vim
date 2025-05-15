function! ShellEscapeForDoubleQuotes(filepath)
  " Returns an escaped filepath to be used in a system() call, wrapped in
  " double quotes
  return substitute(escape(a:filepath, '"'), "'", "''", 'g')
endfunction
