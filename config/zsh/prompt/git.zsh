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

# Display the closest git tag:
# - Keep only tags representing a version
# - Colored orange if the current commit is taggued
# - Colored gray if it's a parent commit
function __prompt-git-tag() {
  local TAG_VERSION_REGEXP="v?[0-9].*"
  local tagName="$(git tag-current)"
  [[ ! $tagName =~ $TAG_VERSION_REGEXP ]] && return

  # Check if commits have been added since last tag
  git-commit-tagged && echo -n " %F{$COLORS[orange]} $tagName" && return
  echo -n " %F{$COLORS[gray7]}炙$tagName%f"
}

# Display the current remote:
# - only if not origin
function __prompt-git-remote() {
  local remoteName="$(git remote-current)"
  [[ $remoteName = 'origin' || $remoteName == '' ]] && return;

  echo " %F{$COLORS[yellow]} $remoteName%f"
}

# Display the current branch:
# - Known branches are color-coded
# - Symbol is added if upstream is gone, detached, need pull/push/force-push
function __prompt-git-branch() {
  local branchName="$(git branch-current)"
  [[ $branchName = '' ]] && return;

  # Detached
  if [[ $branchName = 'HEAD' ]]; then
    branchName=" $(git commit-current)"
    echo " %F{$COLORS[red]}${branchName}%f"
    return
  fi

  # Upstream is gone
  git-branch-gone && echo " %F{$COLORS[red]} ${branchName}%f" && return


  local branchColor="$(__prompt-git-branch-color $branchName)"

  local remoteStatus
  remoteStatus="$(git-branch-remote-status)"
  [[ $remoteStatus = 'local_ahead' ]] && echo -n " %F{$COLORS[$branchColor]}  $branchName%f"
  [[ $remoteStatus = 'local_behind' ]] && echo -n " %F{$COLORS[$branchColor]} $branchName%f"
  [[ $remoteStatus = 'local_diverged' ]] && echo -n " %F{$COLORS[red]} $branchName%f"
  [[ $remoteStatus = 'local_never_pushed' ]] && echo -n " %F{$COLORS[$branchColor]} $branchName%f"
  [[ $remoteStatus = 'local_identical' ]] && echo -n " %F{$COLORS[$branchColor]}$branchName%f"
}

# Get the color of a known branch
function __prompt-git-branch-color() {
  [[ $1 == "master" ]] && echo "blue5" && return;
  [[ $1 == "main" ]] && echo "blue" && return;
  [[ $1 == "develop" ]] && echo "yellow" && return;
  [[ $1 == "heroku" ]] && echo "purple" && return;
  echo "orange"
}

# Returns the number of currently opened issues
function __prompt-github-issues-and-prs() {
  # No GITHUB_TOKEN
  if [[ ! -v GITHUB_TOKEN ]]; then
    echo -n "%F{$COLORS[red]} %f"
    return
  fi

  local gitFolder="$(git root)/.git"

  # Stop early if no .git folder at the root (like in submodules, where it's
  # a file)
  [[ ! -d $gitFolder ]] && return

  local issueCacheFile="${gitFolder}/oroshi_issue_count"
  local prCacheFile="${gitFolder}/oroshi_pr_count"
  local cacheDuration=1440 # In minutes

  # We update the count if file does not exist, or too old
  if [[ ! -r $issueCacheFile ]] || is-older $issueCacheFile $cacheDuration; then
    ghic > $issueCacheFile
  fi
  if [[ ! -r $prCacheFile ]] || is-older $prCacheFile $cacheDuration; then
    ghprc > $prCacheFile
  fi

  local display=""
  local prCount="$(\cat $prCacheFile)"
  if [[ ! $prCount = 0 ]]; then
    display="${display} %F{$COLORS[green]} ${prCount}%f"
  fi
  local issueCount="$(\cat $issueCacheFile)"
  if [[ ! $issueCount = 0 ]]; then
    display="${display} %F{$COLORS[yellow]} ${issueCount}%f"
  fi


  # echo $display
}
# }}}
