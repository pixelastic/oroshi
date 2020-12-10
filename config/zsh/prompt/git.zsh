# Git
# Display git-related information

# Display git flags:
# - If in a submodule
# - If has changes stashed
# - If a rebase is in progress
# - A color-coded status icon
function __prompt-git-flags() {
  git-is-repository || return

  git-is-submodule && echo -n "%F{$COLOR[yellow]} %f"
  git stash show &>/dev/null && echo -n "%F{$COLOR[pink8]} %f"
  git-rebase-inprogress && echo -n "%F{$COLOR[red6]} %f"
  echo -n "$(__prompt-git-status)"
}

# Display a colored coded git symbol
# - Green if no files were changed
# - Red if any file has been added/deleted/modified
# - Purple if files are added to the index
function __prompt-git-status() {
  git-directory-has-staged-files && echo "%F{$COLOR[purple]}ﰖ %f" && return
  git-directory-is-dirty && echo "%F{$COLOR[red]}ﰖ %f" && return
  echo "%F{$COLOR[green]}ﰖ %f"
}

# Display all the git-related informations on the right
function __prompt-git-right() {
  git-is-repository || return

  # Replace all with rebase information
  if git-rebase-inprogress; then
    echo "$(__prompt-git-rebase)"
    return
  fi

  echo -n "$(__prompt-git-tag)"
  echo -n "$(__prompt-git-remote)"
  echo -n "$(__prompt-github-issues)"
  echo -n "$(__prompt-git-branch)"
}

# Display the current state of the rebase:
# - How many steps are there
# - commitId of the current commit being rebased
function __prompt-git-rebase() {
  local currentStep="$(git-rebase-step-current)"
  local maxStep="$(git-rebase-step-max)"

  echo -n "%B%F{$COLOR[red6]} ${currentStep}/${maxStep} %f%b"

  local ontoBranch="$(git-rebase-onto)"
  local ontoColor="$(__prompt-git-branch-color $ontoBranch)"
  local transplantBranch="$(git-rebase-transplant)"
  local transplantColor="$(__prompt-git-branch-color $transplantBranch)"


  echo -n "%F{$COLOR[$ontoColor]}[${ontoBranch:0:8}]%f"
  echo -n "%F{$COLOR[$transplantColor]}[${transplantBranch}]%f"
}

# Display the closest git tag:
# - Colored orange if the current commit is taggued
# - Colored gray if it's a parent commit
function __prompt-git-tag() {
  local tagName="$(git tag-current)"
  [[ $tagName = '' ]] && return
  # The following tag is used at work, but should be ignored
  [[ $tagName = 'empty-commit-branch-to-break-master' ]] && return 

  # Check if commits have been added since last tag
  git-commit-tagged && echo -n " %F{$COLOR[orange]} $tagName" && return
  echo -n " %F{$COLOR[gray7]}炙$tagName%f"
}

# Display the current remote:
# - only if not origin
function __prompt-git-remote() {
  local remoteName="$(git remote-current)"
  [[ $remoteName = 'origin' || $remoteName == '' ]] && return;

  echo " %F{$COLOR[yellow]} $remoteName%f"
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
    echo " %F{$COLOR[red]}${branchName}%f"
    return
  fi

  # Upstream is gone
  git-branch-gone && echo " %F{$COLOR[red]} ${branchName}%f" && return


  local branchColor="$(__prompt-git-branch-color $branchName)"

  local remoteStatus
  remoteStatus="$(git-branch-remote-status)"
  [[ $remoteStatus = 'local_ahead' ]] && echo -n " %F{$COLOR[$branchColor]}  $branchName%f"
  [[ $remoteStatus = 'local_behind' ]] && echo -n " %F{$COLOR[$branchColor]} $branchName%f"
  [[ $remoteStatus = 'local_diverged' ]] && echo -n " %F{$COLOR[red]} $branchName%f"
  [[ $remoteStatus = 'local_never_pushed' ]] && echo -n " %F{$COLOR[$branchColor]} $branchName%f"
  [[ $remoteStatus = 'local_identical' ]] && echo -n " %F{$COLOR[$branchColor]}$branchName%f"
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
function __prompt-github-issues() {
  local cacheFile="$(git root)/.git/oroshi_issue_count"
  local cacheDuration=1440 # In minutes

  # We update the count if file does not exist, or too old
  if [[ ! -r $cacheFile ]] || is-older $cacheFile $cacheDuration; then
    ghic > $cacheFile
  fi

  # We return the content of the file
  local issueCount="$(cat $cacheFile)"

  echo " %F{$COLOR[yellow]} ${issueCount}%f"
}
# }}}

