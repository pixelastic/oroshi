" Git integration in the status line

" GitIsRepo
" Check if the file is part of a git repo
function! GitIsRepo()
  let result = system('git rev-parse')
  return result =~# '^fatal' ? 0 : 1
endfunction

" GitFileStatus
" Returns the file status of the current file
function! GitFileStatus()
  if GitIsRepo() == 0 | return '' | endif

  let filepath = expand('%:p')
  let result = system('git status --porcelain --short "'.filepath.'"')

  if result == '' | return 'Clean' | endif
  if result =~# '^ .' | return 'Dirty' | endif
  return 'Staged'
endfunction

" GitRoot
" Returns the full path to the git repo
function! GitRoot() 
  let dirname = expand('%:p:h')
  let root = system('cd '.ShellEscapeForDoubleQuotes(dirname).' && git root')
  return StrTrim(root)
endfunction


