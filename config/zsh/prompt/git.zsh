# Git
# Display git-related information

# Display git flags:
# - If in a submodule
# - If has changes stashed
# - If a rebase is in progress
# - A color-coded status icon
function __prompt-git-flags() {
  # Do nothing if in a .git folder
  git-is-dot-git-folder && return

  # Or in a non-git repo
  git-is-repository || return

  git-is-submodule && echo -n "%F{$COLORS[yellow]} %f"
  git stash show &>/dev/null && echo -n "%F{$COLORS[pink8]} %f"
  git-rebase-inprogress && echo -n "%F{$COLORS[red6]} %f"
  echo -n "$(__prompt-git-status)"
}

# Display a colored coded git symbol
# - Green if no files were changed
# - Red if any file has been added/deleted/modified
# - Purple if files are added to the index
function __prompt-git-status() {
  git-directory-has-staged-files && echo "%F{$COLORS[purple]}ﰖ %f" && return
  git-directory-is-dirty && echo "%F{$COLORS[red]}ﰖ %f" && return
  echo "%F{$COLORS[green]}ﰖ %f"
}

# Display all the git-related informations on the right
function __prompt-git-right() {
  # Many vit utility functions require ruby, which may not be installed on
  # a brand new machine yet. So we disable all right git info until ruby is
  # available
  [[ -v commands[ruby] ]] || return

  # Also stop if not a git repo
  # echo -n "$(git-is-repository)"
  git-is-repository || return

  # Replace all with rebase information
  if git-rebase-inprogress; then
    echo "$(__prompt-git-rebase)"
    return
  fi

  echo -n "$(__prompt-git-tag)"
  echo -n "$(__prompt-git-remote)"
  echo -n "$(__prompt-github-issues-and-prs)"
  echo -n "$(__prompt-git-branch)"
}

# Display the current state of the rebase:
# - How many steps are there
# - commitId of the current commit being rebased
function __prompt-git-rebase() {
  local currentStep="$(git-rebase-step-current)"
  local maxStep="$(git-rebase-step-max)"

  echo -n "%B%F{$COLORS[red6]} ${currentStep}/${maxStep} %f%b"

  local ontoBranch="$(git-rebase-onto)"
  local ontoColor="$(__prompt-git-branch-color $ontoBranch)"
  local transplantBranch="$(git-rebase-transplant)"
  local transplantColor="$(__prompt-git-branch-color $transplantBranch)"


  echo -n "%F{$COLORS[$ontoColor]}[${ontoBranch:0:8}]%f"
  echo -n "%F{$COLORS[$transplantColor]}[${transplantBranch}]%f"
}

# Display the most relevant git tag
function __prompt-git-tag() {
  echo -n "$(OROSHI_IS_PROMPT=1 git-tag-colorize --with-icon) "
}

# Display the current remote:
# - only if not origin
function __prompt-git-remote() {
  local remoteName="$(git-remote-current)"
  [[ $remoteName = 'origin' ]] && return;

  echo -n "$(OROSHI_IS_PROMPT=1 git-remote-colorize --with-icon) "
}

# Display the current branch
function __prompt-git-branch() {
  echo -n "$(OROSHI_IS_PROMPT=1 git-branch-colorize --with-icon)"
}

# Returns the number of currently opened issues
function __prompt-github-issues-and-prs() {
  # No GITHUB_TOKEN
  if [[ ! -v GITHUB_TOKEN_READONLY ]]; then
    echo -n "%F{$COLORS[red]}  %f"
    return
  fi

  local gitFolder="$(git root)/.git"

  # Stop early if no .git folder at the root (like in submodules, where it's
  # a file)
  [[ ! -d $gitFolder ]] && return

  # Stop if not in a GitHub repo
  git-directory-is-github || return

  local issueCacheFile="${gitFolder}/oroshi_issue_count"
  local prCacheFile="${gitFolder}/oroshi_pr_count"
  local cacheDuration=1440 # In minutes

  # We update the count if file does not exist, or too old
  if [[ ! -r $issueCacheFile ]] || is-older $issueCacheFile $cacheDuration; then
    git-issue-count > $issueCacheFile
  fi
  if [[ ! -r $prCacheFile ]] || is-older $prCacheFile $cacheDuration; then
    git-pr-count > $prCacheFile
  fi

  local display=""
  local prCount="$(\cat $prCacheFile)"
  if [[ ! $prCount = 0 ]]; then
    display="${display} %F{$COLORS[purple]} ${prCount}%f"
  fi
  local issueCount="$(\cat $issueCacheFile)"
  if [[ ! $issueCount = 0 ]]; then
    display="${display} %F{$COLORS[yellow]} ${issueCount}%f"
  fi

  echo $display
}
# }}}
