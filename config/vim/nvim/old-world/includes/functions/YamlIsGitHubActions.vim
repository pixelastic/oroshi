" Check if the current file is a GitHub Actions workflow
function! YamlIsGitHubActions()
  let currentFilepath = expand('%:p')

  " match returns a negative number if it can't find a match
  if match(currentFilepath, '\.github/workflows') < 0
    return 0
  endif

  return 1
endfun
