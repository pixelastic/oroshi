" Returns a string representation of the project
" - Colored based on colors in PROJECT_
" - With an icon matching the extension
" - With the filetype as detected by vim if different
function! ProjectStatusLine()
  let filepath = expand('%:p')
  let projectKey = StrTrim(system('project-by-path ' . filepath))
  let projectName = tolower(projectKey)

  " vint: -ProhibitUsingUndeclaredVariable
  execute 'let icon=$PROJECT_' . projectKey . '_ICON'

  let projectStatus=''
  let projectStatus.='%#ProjectPre_' . projectKey . '# %*'
  let projectStatus.='%#Project_' . projectKey . '#' . icon . projectName . ' %*'
  let projectStatus.='%#ProjectPost_' . projectKey . '#%*'
  " vint: +ProhibitUsingUndeclaredVariable
  "
  return projectStatus
endfunction
