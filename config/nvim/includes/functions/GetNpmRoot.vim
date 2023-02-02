function! GetNpmRoot()
  " Use caching
  if exists('b:npmRoot')
    return b:npmRoot
  endif

  " Check if has a package.json
  let workingDir = expand('%:h')
  let npmRoot = simplify(
        \StrTrim(system('cd '. workingDir. ' && npm root')) . '/../'
        \)
  let packagePath = npmRoot . '/../package.json'

  if filereadable(packagePath)
    let b:npmRoot = npmRoot
  else
    let b:npmRoot = workingDir
  endif

  return b:npmRoot
endfunction
