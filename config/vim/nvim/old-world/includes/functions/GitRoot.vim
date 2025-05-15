function! GitRoot()
  " Use caching
  if exists('b:gitRoot')
    return b:gitRoot
  endif

  let b:gitRoot=StrTrim(system('git-directory-root-bin -f'))

  return b:gitRoot
endfunction
