# Git
# Display git-related information

# Display a colored coded git symbol
# - Green if no files were changed
# - Red if any file has been added/deleted/modified
# - Purple if files are added to the index
function oroshi-prompt-git-status-populate() {
  OROSHI_PROMPT_PARTS[git-status]=""
  (( $GIT_DIRECTORY_IS_REPOSITORY )) || return

  # Staged files
  if (( $GIT_DIRECTORY_HAS_STAGED_FILES )); then
    OROSHI_PROMPT_PARTS[git-status]="%F{$COLOR_ALIAS_GIT_MODIFIED}ﰖ%f"
    return
  fi

  # Dirty directory
  if (( $GIT_DIRECTORY_IS_DIRTY )); then
    OROSHI_PROMPT_PARTS[git-status]="%F{$COLOR_ALIAS_ERROR}ﰖ%f"
    return
  fi

  # Clean directory
  OROSHI_PROMPT_PARTS[git-status]="%F{$COLOR_ALIAS_SUCCESS}ﰖ%f"
}

# Display a colored branch, with icons
function oroshi-prompt-git-branch-populate() {
  OROSHI_PROMPT_PARTS[git-branch]=""
  (( $GIT_DIRECTORY_IS_REPOSITORY )) || return

  OROSHI_PROMPT_PARTS[git-branch]="$(OROSHI_IS_PROMPT=1 git-branch-colorize $GIT_BRANCH_CURRENT --with-icon)"
}

# Display the most relevant git tag
function oroshi-prompt-git-tag-populate() {
  OROSHI_PROMPT_PARTS[git-tag]=""
  (( $GIT_DIRECTORY_IS_REPOSITORY )) || return

  OROSHI_PROMPT_PARTS[git-tag]="$(OROSHI_IS_PROMPT=1 git-tag-colorize --with-icon)"
}

# Display the current remote
function oroshi-prompt-git-remote-populate() {
  OROSHI_PROMPT_PARTS[git-remote]=""
  (( $GIT_DIRECTORY_IS_REPOSITORY )) || return

  [[ $GIT_REMOTE_CURRENT == 'origin' ]] && return;

  OROSHI_PROMPT_PARTS[git-remote]="$(OROSHI_IS_PROMPT=1 git-remote-colorize $GIT_REMOTE_CURRENT--with-icon)"
}

# Check if in a submodule
function oroshi-prompt-git-is-submodule-populate() {
  OROSHI_PROMPT_PARTS[git-is-submodule]=""
  (( $GIT_DIRECTORY_IS_REPOSITORY )) || return

  git-is-submodule || return

  OROSHI_PROMPT_PARTS[git-is-submodule]="%F{$COLOR_ALIAS_LOCAL_DEPENDENCY} %f"
}

# Check if has stashes
function oroshi-prompt-git-has-stash-populate() {
  OROSHI_PROMPT_PARTS[git-has-stash]=""
  (( $GIT_DIRECTORY_IS_REPOSITORY )) || return

  git-stash-exists || return

  OROSHI_PROMPT_PARTS[git-has-stash]="%F{$COLOR_ALIAS_GIT_STASH} %f"
}

# Check if rebase is in progress
function oroshi-prompt-git-rebase-in-progress-populate() {
  OROSHI_PROMPT_PARTS[git-rebase-in-progress]=""

  git-rebase-in-progress || return

  OROSHI_PROMPT_PARTS[git-rebase-in-progress]="%F{$COLOR_ALIAS_GIT_REBASE} %f"
}

# Display the current state of the rebase:
# - How many steps are there
# - commitId of the current commit being rebased
function oroshi-prompt-git-rebase-status-populate() {
  OROSHI_PROMPT_PARTS[git-rebase-status]=""
  (( $GIT_DIRECTORY_IS_REPOSITORY )) || return

  git-rebase-in-progress || return


  local currentStep="$(git-rebase-step-current)"
  local maxStep="$(git-rebase-step-max)"

  OROSHI_PROMPT_PARTS[git-rebase-status]+="%B%F{$COLOR_ALIAS_GIT_REBASE} ${currentStep}/${maxStep}%f%b"

  local ontoBranch="$(git-rebase-onto)"
  local ontoColor="$(git-branch-color $ontoBranch)"
  local transplantBranch="$(git-rebase-transplant)"
  local transplantColor="$(git-branch-color $transplantBranch)"


  OROSHI_PROMPT_PARTS[git-rebase-status]+="%F{${(P)${:-COLOR_${ontoColor}}}[${ontoBranch:0:8}]%f"
  OROSHI_PROMPT_PARTS[git-rebase-status]+="%F{${(P)${:-COLOR_${transplantColor}}}[${transplantBranch}]%f"
}

# Returns the number of currently opened issues
function oroshi-prompt-git-issues-populate() {
  OROSHI_PROMPT_PARTS[git-issues]=""
  (( $GIT_DIRECTORY_IS_REPOSITORY )) || return
  git-directory-is-github || return

  # No GITHUB_TOKEN
  if [[ $GITHUB_TOKEN_READONLY == "" ]]; then
    OROSHI_PROMPT_PARTS[git-issues]="%F{$COLOR_ALIAS_ERROR} %f"
    return
  fi

  local projectName="$(git-github-remote-project)"
  local cacheFolderPath="/tmp/oroshi/github/${projectName}"
  mkdir -p $cacheFolderPath

  local issuesCacheFile="${cacheFolderPath}/issues"
  local cacheDuration=1440 # In minutes

  # We update the count if file does not exist, or too old
  if [[ ! -r $issuesCacheFile ]] || is-older $issuesCacheFile $cacheDuration; then
    git-issue-count > $issuesCacheFile
  fi

  local issueCount="$(<$issuesCacheFile)"
  if [[ ! $issueCount = 0 ]]; then
    OROSHI_PROMPT_PARTS[git-issues]="%F{$COLOR_ALIAS_GIT_ISSUE} ${issueCount}%f"
  fi
}

# Returns the number of currently opened pullrequests
function oroshi-prompt-git-pullrequests-populate() {
  OROSHI_PROMPT_PARTS[git-pullrequests]=""
  (( $GIT_DIRECTORY_IS_REPOSITORY )) || return
  git-directory-is-github || return

  # No GITHUB_TOKEN
  if [[ $GITHUB_TOKEN_READONLY == "" ]]; then
    OROSHI_PROMPT_PARTS[git-pullrequests]="%F{$COLOR_ALIAS_ERROR} %f"
    return
  fi

  local projectName="$(git-github-remote-project)"
  local cacheFolderPath="/tmp/oroshi/github/${projectName}"
  mkdir -p $cacheFolderPath

  local pullrequestsCacheFile="${cacheFolderPath}/pullrequests"
  local cacheDuration=1440 # In minutes

  # We update the count if file does not exist, or too old
  if [[ ! -r $pullrequestsCacheFile ]] || is-older $pullrequestsCacheFile $cacheDuration; then
    git-pullrequest-count > $pullrequestsCacheFile
  fi

  local pullrequestCount="$(<$pullrequestsCacheFile)"
  if [[ ! $pullrequestCount = 0 ]]; then
    OROSHI_PROMPT_PARTS[git-pullrequests]="%F{$COLOR_ALIAS_GIT_PULLREQUEST} ${pullrequestCount}%f"
  fi
}

# }}}
