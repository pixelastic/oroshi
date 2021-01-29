" Linting errors through either Syntastic or CoC
" TODO: Enter should add the endfunction in vimscript

" Returns an array of [errorCount, warningCount] from CoC
function! LintStatusLineCoC()
  let info = get(b:, 'coc_diagnostic_info', {})
  if empty(info)
    return []
  endif
  return [get(info, 'error', 0), get(info, 'warning', 0)]
endfunction

" Returns an array of [errorCount, warningCount] from Syntastic
function! LintStatusLineSyntastic()
  let g:syntastic_stl_format='%e:%w'
  let rawStatus = split(SyntasticStatuslineFlag(), ':')
  if empty(rawStatus)
    return []
  endif
  return [str2nr(rawStatus[0]), str2nr(rawStatus[1])]
endfunction

" Returns a colored string of errors and warning count
function! LintStatusLine()
  " Check CoC first, and fallback to syntastic
  let lintStatus = LintStatusLineCoC()
  if empty(lintStatus)
    let lintStatus = LintStatusLineSyntastic()
  endif
  if empty(lintStatus)
    return ''
  endif

  let errorCount = lintStatus[0]
  let warningCount = lintStatus[1]

  let statusLine = []
  if (errorCount > 0)
    call add(statusLine, '%#StatusLineError# '.errorCount.'%*')
  endif
  if (warningCount > 0)
    call add(statusLine, '%#StatusLineWarning# '.warningCount.'%*')
  endif

  if empty(statusLine)
    return ''
  endif

  return join(statusLine, ' ')
endfunction
