# Fancy prompt.

# init
setopt PROMPT_SUBST
autoload -U promptinit
promptinit

# Left part
# user@host:/path/ %
PROMPT='$promptUsername@$promptHostname:$(getPromptPath) $(getPromptHash) '
# User
promptUsername="$FG[$promptColor[username]]%n$FX[reset]"
# Hostname
promptHostname="$FG[$promptColor[hostname]]%m$FX[reset]"
# Path
# getPromptPath() {{{
# This will return a formatted path.
# - If more than 4 directories, will only keep the first and the last two
# - Will prepend a ! and display it in red if not writable
function getPromptPath() {
  local promptPath=$PWD
  local splitPath
  splitPath=(${(s:/:)PWD})

  # Keep only first and last dirs if too long
  if [[ ${#splitPath[*]} -ge 4 ]]; then
    promptPath=/${splitPath[1]}/../${splitPath[-2]}/${splitPath[-1]}/
  fi

  # Prefix a ! if not writable
  if [[ ! -w $PWD ]]; then
    promptPath=!$promptPath
  fi

  # Checking if I'm the owner or am in the group of this dir
  local promptPathColor=$promptColor[pathRestricted]
  if [[ $UID = $(stat --print "%u" $PWD) ]]; then
    # I'm the owner
    promptPathColor=$promptColor[pathOwner]
    else
      local pathGroup=$(stat --print "%G" $PWD)
      local userGroups="($(groups $USER))"
      if [[ $userGroups =~ $pathGroup ]]; then
        # I'm in the group
        promptPathColor=$promptColor[pathGroup]
      fi
  fi

  echo "$FG[$promptPathColor]$promptPath$FX[reset]"
}
# }}}
# Directory indicator
# getPromptHash() {{{
function getPromptHash() {
  local promptHashColor=''
  local promptHash='%#'

  if [[ $promptIsGit = 1 ]]; then
    echo $(getPromptHashGit)
    return
  fi

  echo "$FG[$promptHashColor]$promptHash$FX[reset]"
}
# }}}
# getPromptHashGit() {{{
function getPromptHashGit() {
  local gitStatus="$(git status-short)"
  local promptHashColor=$promptColor[repoClean]
  local promptHash='±'

  # Does it have modified or new files ?
  local gitHasModifiedFiles=0
  if [[ $gitStatus =~ ' . ' || $gitStatus =~ '\?\?' ]]; then
    gitHasModifiedFiles=1
  fi

  # Does it have staged files ?
  local gitHasStagedFiles=0
  if [[ $gitStatus =~ '.  ' ]]; then
    gitHasStagedFiles=1
  fi

  # Repo is clean, but there are files in the index waiting for a commit
  if [[ $gitHasModifiedFiles = 0 && $gitHasStagedFiles = 1 ]]; then
    promptHashColor=$promptColor[repoStaged]
    promptHash="${promptHash}*"
  fi

  # Files have been changed or added, but nothing is ready to be commited
  if [[ $gitHasModifiedFiles = 1 && $gitHasStagedFiles = 0 ]]; then
    promptHashColor=$promptColor[repoDirty]
  fi

  # Files have been added/modified and others are ready to be comitted
  if [[ $gitHasModifiedFiles = 1 && $gitHasStagedFiles = 1 ]]; then
    promptHashColor=$promptColor[repoDirtyAndStaged]
    promptHash="${promptHash}*"
  fi

  echo "$FG[$promptHashColor]$promptHash$FX[reset]"
}
# }}}

# Right part
RPROMPT='$(getPromptRepoTag)$(getPromptRepoSubmodule)$(getPromptRepoRebase)$(getPromptRepoBranch)'
# Tag
# getPromptRepoTag() {{{
function getPromptRepoTag() {
  if [[ $promptIsGit = 0 ]]; then
    return
  fi

  local promptRepoTag="$(git current-tag)"
  if [[ $promptRepoTag != '' ]]; then
    echo "$FG[$promptColor[tag]]$promptRepoTag$FX[reset] "
  fi
}
# }}}
# Submodule
# getPromptRepoSubmodule() {{{
function getPromptRepoSubmodule() {
  if [[ $promptIsGit = 0 ]]; then
    return
  fi

  local isSubmodule="$(git is-submodule)"
  if [[ $isSubmodule = 1 ]]; then
    echo "$FG[$promptColor[submodule]]↯$FX[reset] "
  fi
}
# }}}
# Rebase
# getPromptRepoRebase() {{{
function getPromptRepoRebase() {
  if [[ $promptIsGit = 0 ]]; then
    return
  fi

  local rebaseInternalDir="$promptGitRoot/.git/rebase-apply"
  local isRebasingFile="$rebaseInternalDir/rebasing"

  if [[ -r $isRebasingFile ]]; then
    local maxRebase=$(cat $rebaseInternalDir/last)
    local nextRebase=$(cat $rebaseInternalDir/next)
    echo "$FG[$promptColor[rebase]]${nextRebase}/${maxRebase} ⚶ $FX[reset]"
  fi
}
# }}}
# Branch
# getPromptRepoBranch() {{{
function getPromptRepoBranch() {
  if [[ $promptIsGit = 0 ]]; then
    return
  fi

  local promptBranch="$(git current-branch)"
  local promptBranchColor=$promptBranch[branchDefault]

  # No branch found
  if [[ promptBranch = '' ]]; then
    return
  fi

  # Branch color
  if [[ $promptBranch = 'HEAD' ]]; then
    promptBranchColor=$promptColor[branchDetached]
    promptBranch="$(getGitShortHash) ⭠"
  fi
  if [[ $promptBranch = 'master' ]]; then
    promptBranchColor=$promptColor[branchMaster]
  fi
  if [[ $promptBranch = 'develop' ]]; then
    promptBranchColor=$promptColor[branchDevelop]
  fi
  if [[ $promptBranch =~ '^bugfix/' ]]; then
    promptBranch=${promptBranch//bugfix\//}
    promptBranchColor=$promptColor[branchBugfix]
  fi
  if [[ $promptBranch =~ '^feature/' ]]; then
    promptBranch=${promptBranch//feature\//}
    promptBranchColor=$promptColor[branchFeature]
  fi
  if [[ $promptBranch =~ '^review/' ]]; then
    promptBranch=${promptBranch//review\//}
    promptBranchColor=$promptColor[branchReview]
  fi
  if [[ $promptBranch = 'gh-pages' ]]; then
    promptBranchColor=$promptColor[branchGhPages]
  fi

  # Adding push indicator
  local gitStatus="$(git status)"
  if [[ $gitStatus =~ 'Your branch is ahead of' ]]; then
    promptBranch="⇪ $promptBranch"
  fi
  
  echo "$FG[$promptBranchColor]$promptBranch$FX[reset]"
}
# }}}


# isGit() {{{
function isGit() {
  # Avoid git internal directory
  if [[ $PWD =~ '\.git' ]]; then
    echo 0
    return
  fi

  if [[ $(git --work-tree="$PWD" status 2>/dev/null) != '' ]]; then
    # Avoid doing it in a bare repo
    if [[ $(git rev-parse --is-bare-repository) == 'true' ]]; then
      echo 0;
      return
    fi

    echo 1
    return
  fi

  echo 0
}
# }}}
# getGitRoot() {{{
function getGitRoot() {
  if [[ $(isGit) = 0 ]]; then
    return
  fi
  echo $(git root)
}
# }}}
# getGitShortHash() {{{
function getGitShortHash() {
  if [[ $(isGit) = 0 ]]; then
    return
  fi
  echo $(git log --pretty=format:'%h' -n 1)
echo 
}
# }}}

# chpwd() {{{
function chpwd() {
  # Caching git information
  promptIsGit=$(isGit)
  promptGitRoot=$(getGitRoot)
  # Window title
  print -Pn "\e]2;%n@%m:%~/\a"
}
# }}}

