" Returns a string representation of the project
" - Colored based on colors in PROJECT_
" - With an icon matching the extension
" - With the filetype as detected by vim if different
function! ProjectStatusLine()
  " Disable in vim-plug update window
  if &filetype ==# 'vim-plug'
    return
  endif

  let filepath = expand('%:p')
  let projectKey = StrTrim(system('project-by-path ' . filepath))
  let projectName = tolower(projectKey)

  " vint: -ProhibitUsingUndeclaredVariable
  execute 'let icon=$PROJECT_' . projectKey . '_ICON'
  execute 'let shouldHideName=$PROJECT_' . projectKey . '_HIDE_NAME_IN_PROMPT'

  let projectStatus=''
  let projectStatus.='%#ProjectPre_' . projectKey . '# %*'
  let projectStatus.='%#Project_' . projectKey . '#' . icon
  if shouldHideName ==# '0'
    let projectStatus.=projectName
  endif
  let projectStatus.=' %*'
  let projectStatus.='%#ProjectPost_' . projectKey . '#%*'
  " vint: +ProhibitUsingUndeclaredVariable
  "
  return projectStatus
endfunction
