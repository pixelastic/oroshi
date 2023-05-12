# shellcheck disable=SC2154
# Git
# Display git-related information

# Display a colored coded git symbol
# - Green if no files were changed
# - Red if any file has been added/deleted/modified
# - Purple if files are added to the index
function oroshi-prompt-populate:git_status() {
  OROSHI_PROMPT_PARTS[git-status]=""
  # Stop if not in a git repo
  (( $GIT_DIRECTORY_IS_REPOSITORY )) || return
  # Or if in a .git/ folder
  git-directory-is-dot-git && return

  # Staged files
  if git-directory-has-staged-files; then
    OROSHI_PROMPT_PARTS[git_status]="%F{$COLOR_ALIAS_GIT_TRACKED}ﰖ%f"
    return
  fi

  # Dirty directory
  if git-directory-is-dirty; then
    OROSHI_PROMPT_PARTS[git_status]="%F{$COLOR_ALIAS_GIT_UNTRACKED}ﰖ%f"
    return
  fi

  # Clean directory
  OROSHI_PROMPT_PARTS[git_status]="%F{$COLOR_ALIAS_SUCCESS}ﰖ%f"
}

# Display a colored branch, with icons
function oroshi-prompt-populate:git_branch() {
  OROSHI_PROMPT_PARTS[git_branch]=""
  (( $GIT_DIRECTORY_IS_REPOSITORY )) || return

  OROSHI_PROMPT_PARTS[git_branch]="$(OROSHI_IS_PROMPT=1 git-branch-colorize --with-icon)"
}

# Display the most relevant git tag
function oroshi-prompt-populate:git_tag() {
  OROSHI_PROMPT_PARTS[git_tag]=""
  (( $GIT_DIRECTORY_IS_REPOSITORY )) || return

  OROSHI_PROMPT_PARTS[git_tag]="$(OROSHI_IS_PROMPT=1 git-tag-colorize --with-icon)"
}

# Display the current remote
function oroshi-prompt-populate:git_remote() {
  OROSHI_PROMPT_PARTS[git_remote]=""
  (( $GIT_DIRECTORY_IS_REPOSITORY )) || return

  local currentRemoteName="$(git-remote-current)"
  [[ $currentRemoteName == 'origin' ]] && return;

  OROSHI_PROMPT_PARTS[git_remote]="$(OROSHI_IS_PROMPT=1 git-remote-colorize --with-icon)"
}

# Check if in a submodule
function oroshi-prompt-populate:git_is_submodule() {
  OROSHI_PROMPT_PARTS[git_is_submodule]=""
  (( $GIT_DIRECTORY_IS_REPOSITORY )) || return

  git-is-submodule || return

  OROSHI_PROMPT_PARTS[git_is_submodule]="%F{$COLOR_ALIAS_GIT_SUBMODULE} %f"
}

# Check if has stashes
function oroshi-prompt-populate:git_has_stash() {
  OROSHI_PROMPT_PARTS[git_has_stash]=""
  (( $GIT_DIRECTORY_IS_REPOSITORY )) || return

  git-stash-exists || return

  OROSHI_PROMPT_PARTS[git_has_stash]="%F{$COLOR_ALIAS_GIT_STASH} %f"
}

# Check if rebase is in progress
function oroshi-prompt-populate:git_rebase_in_progress() {
  OROSHI_PROMPT_PARTS[git_rebase_in_progress]=""

  git-rebase-in-progress || return

  OROSHI_PROMPT_PARTS[git_rebase_in_progress]="%F{$COLOR_ALIAS_GIT_REBASE} %f"
}

# Display the current state of the rebase:
# - How many steps are there
# - commitId of the current commit being rebased
function oroshi-prompt-populate:git_rebase_status() {
  OROSHI_PROMPT_PARTS[git_rebase_status]=""
  (( $GIT_DIRECTORY_IS_REPOSITORY )) || return

  git-rebase-in-progress || return


  local currentStep="$(git-rebase-step-current)"
  local maxStep="$(git-rebase-step-max)"

  OROSHI_PROMPT_PARTS[git_rebase_status]+="%B%F{$COLOR_ALIAS_GIT_REBASE} ${currentStep}/${maxStep}%f%b"

  local ontoBranch="$(git-rebase-onto)"
  local ontoColor="$(git-branch-color $ontoBranch)"
  local transplantBranch="$(git-rebase-transplant)"
  local transplantColor="$(git-branch-color $transplantBranch)"


  OROSHI_PROMPT_PARTS[git_rebase_status]+="%F{${(P)${:-COLOR_${ontoColor}}}[${ontoBranch:0:8}]%f"
  OROSHI_PROMPT_PARTS[git_rebase_status]+="%F{${(P)${:-COLOR_${transplantColor}}}[${transplantBranch}]%f"
}

# Returns the number of currently opened issues
function oroshi-prompt-populate:git_issues() {
  OROSHI_PROMPT_PARTS[git_issues]=""
  (( $GIT_DIRECTORY_IS_REPOSITORY )) || return
  git-directory-is-github || return

  # No GITHUB_TOKEN
  if [[ $GITHUB_TOKEN_READONLY == "" ]]; then
    OROSHI_PROMPT_PARTS[git_issues]="%F{$COLOR_ALIAS_ERROR} %f"
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
    OROSHI_PROMPT_PARTS[git_issues]="%F{$COLOR_ALIAS_GIT_ISSUE} ${issueCount}%f"
  fi
}

# Returns the number of currently opened pullrequests
function oroshi-prompt-populate:git_pullrequests() {
  OROSHI_PROMPT_PARTS[git_pullrequests]=""
  (( $GIT_DIRECTORY_IS_REPOSITORY )) || return
  git-directory-is-github || return

  # No GITHUB_TOKEN
  if [[ $GITHUB_TOKEN_READONLY == "" ]]; then
    OROSHI_PROMPT_PARTS[git_pullrequests]="%F{$COLOR_ALIAS_ERROR} %f"
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
    OROSHI_PROMPT_PARTS[git_pullrequests]="%F{$COLOR_ALIAS_GIT_PULLREQUEST} ${pullrequestCount}%f"
  fi
}

# }}}
