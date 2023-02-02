function! GetRepoRoot()
  " Use caching
  if exists('b:repoRoot')
    return b:repoRoot
  endif

  let workingDir = expand('%:h')

  " Check if git
  let gitRoot = system('cd '.workingDir.' && git rev-parse --show-toplevel')
  if gitRoot !~# '^fatal'
    let b:repoRoot = StrTrim(gitRoot)
    return b:repoRoot
  endif

  let b:repoRoot = workingDir
  return b:repoRoot
endfunction
