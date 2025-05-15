" PUG
" Using ## (as in ruby) for string interpolation
inoremap <buffer> ## #{}<Left>
" Default to //- for comment, so they don't show in the HTML
setlocal commentstring=//-\ %s

" Folding {{{
function! PugFoldExpr(lnum)
  if getline(a:lnum) =~? '\v^\s*$'
    return '-1'
  endif

  let this_indent = IndentLevel(a:lnum)
  let next_indent = IndentLevel(NextNonBlankLine(a:lnum))

  if next_indent == this_indent
    return this_indent
  elseif next_indent < this_indent
    return this_indent
  elseif next_indent > this_indent
    return '>' . next_indent
  endif

  return '0'
endfunction
setlocal foldexpr=PugFoldExpr(v:lnum)
setlocal foldmethod=expr
" }}}
