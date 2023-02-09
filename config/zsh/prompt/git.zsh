# Git
# Display git-related information

# Display git flags:
# - If in a submodule
# - If has changes stashed
# - If a rebase is in progress
# - A color-coded status icon
function __prompt-git-flags() {
  # Do nothing if not in a git repo
  (( $GIT_DIRECTORY_IS_REPOSITORY )) || return

  # Quick display: we don't display anything
  if [[ $OROSHI_PROMPT_ENHANCED_MODE == "0" ]]; then
    return
  fi

  # Do nothing if in a .git folder
  git-directory-is-dot-git && return

  git-is-submodule && echo -n "%F{$COLOR_ALIAS_LOCAL_DEPENDENCY} %f"
  (( $GIT_STASH_EXISTS )) && echo -n "%F{$COLOR_ALIAS_GIT_STASH} %f"
  git-rebase-inprogress && echo -n "%F{$COLOR_ALIAS_GIT_REBASE} %f"
}

# Display a colored coded git symbol
# - Green if no files were changed
# - Red if any file has been added/deleted/modified
# - Purple if files are added to the index
function __prompt-git-status() {
  (( $GIT_DIRECTORY_HAS_STAGED_FILES )) && echo -n "%F{$COLOR_ALIAS_GIT_MODIFIED}ﰖ %f" && return
  (( $GIT_DIRECTORY_IS_DIRTY )) && echo -n "%F{$COLOR_ALIAS_ERROR}ﰖ %f" && return
  echo -n "%F{$COLOR_ALIAS_SUCCESS}ﰖ %f"
}

# Display all the git-related informations on the right
function __prompt-git-right() {
  # Stop if not a git repo
  (( $GIT_DIRECTORY_IS_REPOSITORY )) || return

  # Quick display: only the branch name
  if [[ $OROSHI_PROMPT_ENHANCED_MODE == "0" ]]; then
    echo -n "%F{$COLOR_ALIAS_UI}${GIT_BRANCH_CURRENT}%f"
    return
  fi


  # Replace all with rebase information
  if git-rebase-inprogress; then
    __prompt-git-rebase
    return
  fi

  __prompt-git-tag
  __prompt-git-remote
  __prompt-github-issues-and-prs
  __prompt-git-branch
}

# Display the current state of the rebase:
# - How many steps are there
# - commitId of the current commit being rebased
function __prompt-git-rebase() {
  local currentStep="$(git-rebase-step-current)"
  local maxStep="$(git-rebase-step-max)"

  echo -n "%B%F{$COLOR_ALIAS_GIT_REBASE} ${currentStep}/${maxStep} %f%b"

  local ontoBranch="$(git-rebase-onto)"
  local ontoColor="$(__prompt-git-branch-color $ontoBranch)"
  local transplantBranch="$(git-rebase-transplant)"
  local transplantColor="$(__prompt-git-branch-color $transplantBranch)"


  echo -n "%F{${(P)${:-COLOR_${ontoColor}}}[${ontoBranch:0:8}]%f"
  echo -n "%F{${(P)${:-COLOR_${transpantColor}}}[${transplantBranch}]%f"
}

# Display the most relevant git tag
function __prompt-git-tag() {
  local gitTag="$(OROSHI_IS_PROMPT=1 git-tag-colorize --with-icon)"
  [[ $gitTag == "" ]] && echo -n "${gitTag} "
}

# Display the current remote:
# - only if not origin
function __prompt-git-remote() {
  [[ $GIT_REMOTE_CURRENT == 'origin' ]] && return;

  echo -n "$(OROSHI_IS_PROMPT=1 git-remote-colorize $GIT_REMOTE_CURRENT --with-icon) "
}

# Display the current branch
function __prompt-git-branch() {
  echo -n "$(OROSHI_IS_PROMPT=1 git-branch-colorize $GIT_BRANCH_CURRENT --with-icon)"
}

# Returns the number of currently opened issues
function __prompt-github-issues-and-prs() {
  # No GITHUB_TOKEN
  if [[ ! -v GITHUB_TOKEN_READONLY ]]; then
    echo -n "%F{$COLOR_ALIAS_ERROR}  %f"
    return
  fi

  local gitFolder="${GIT_DIRECTORY_ROOT}/.git"

  # Stop early if no .git folder at the root (like in submodules, where it's
  # a file)
  [[ ! -d $gitFolder ]] && return

  # Stop if not in a GitHub repo
  (( $GIT_DIRECTORY_IS_GITHUB )) || return

  local issueCacheFile="${gitFolder}/oroshi_issue_count"
  local prCacheFile="${gitFolder}/oroshi_pr_count"
  local cacheDuration=1440 # In minutes

  # We update the count if file does not exist, or too old
  if [[ ! -r $issueCacheFile ]] || is-older $issueCacheFile $cacheDuration; then
    git-issue-count > $issueCacheFile
  fi
  if [[ ! -r $prCacheFile ]] || is-older $prCacheFile $cacheDuration; then
    git-pullrequest-count > $prCacheFile
  fi

  local display=""
  local prCount="$(<$prCacheFile)"
  if [[ ! $prCount = 0 ]]; then
    display="${display}%F{$COLOR_ALIAS_GIT_PULL_REQUEST} ${prCount}%f "
  fi
  local issueCount="$(<$issueCacheFile)"
  if [[ ! $issueCount = 0 ]]; then
    display="${display}%F{$COLOR_ALIAS_GIT_ISSUE} ${issueCount}%f "
  fi
  echo -n $display
}
# }}}
