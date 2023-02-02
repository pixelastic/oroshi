function! StrUncomment(txt)
  " Removes all comment and fold marker of a string
  let line = a:txt

  " Remove comments
  let comments = split(&commentstring, '%s')
  let comments[0] = escape(comments[0], '*')

  let line = substitute(line, '^\s*' . StrTrim(comments[0]), '', '')
  if len(comments) > 1
    let comments[1] = escape(comments[1], '*')
    let line = substitute(line, comments[1] . '$', '', '')
  endif

  " Remove folding marker
  if (&foldmethod ==# 'marker')
    let foldmarkers = split(&foldmarker, ',')
    let foldmarkers[0] = escape(foldmarkers[0], '*')

    let line = substitute(line, foldmarkers[0] . '.*$', '', '')

    " Remove trailing comment used to add the previously deleted foldmarker
    if strlen(StrTrim(comments[0])) > 1
      let line = substitute(line, comments[0] . '.*$', '', '')
    endif
  endif

  " Trim title
  let line = StrTrim(line)

  return line
endfunction
