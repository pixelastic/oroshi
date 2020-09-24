
# Git  {{{
# Will display informations about the current git repository (if any):
# - If in a submodule
# - If has changes stashes
# - If the repo is dirty
function oroshi_prompt_git_flags() {
  git-is-repository || return

  git-is-submodule && echo -n "%F{$COLOR[yellow]} %f"
  git stash show &>/dev/null && echo -n "%F{$COLOR[pink8]} %f"
  git-rebase-inprogress && echo -n "%F{$COLOR[red6]} %f"

  echo "$(oroshi_prompt_git_dirty)"
}
# }}}
# Git: Dirty {{{
function oroshi_prompt_git_dirty() {
  # Staged files
  if git-directory-has-staged-files; then
    echo "%F{$COLOR[purple]}ﰖ%f"
    return
  fi

  # Modified, deleted or newly added files
  if git-directory-is-dirty; then
    echo "%F{$COLOR[red]}ﰖ%f"
    return
  fi

  echo "%F{$COLOR[green]}ﰖ%f"
}
# }}}
#
#
#
# Git (right) {{{
function oroshi_prompt_git_right() {
  git-is-repository || return

  # Replace all with rebase information
  if git-rebase-inprogress; then
    echo "$(oroshi_prompt_git_rebase)"
    return
  fi

  echo -n "$(oroshi_prompt_git_tag)"
  echo -n "$(oroshi_prompt_git_remote)"
  echo -n "$(oroshi_prompt_git_branch)"
}
# }}}
# Git: Rebase {{{
function oroshi_prompt_git_rebase() {
  local currentStep="$(git-rebase-step-current)"
  local maxStep="$(git-rebase-step-max)"

  echo -n "%B%F{$COLOR[red6]} ${currentStep}/${maxStep} %f%b"

  local ontoBranch="$(git-rebase-onto)"
  local ontoColor="$(oroshi_prompt_git_branch_color $ontoBranch)"
  local transplantBranch="$(git-rebase-transplant)"
  local transplantColor="$(oroshi_prompt_git_branch_color $transplantBranch)"


  echo -n "%F{$COLOR[gray]}[trunk]%f"
  echo -n "%F{$COLOR[$ontoColor]}[${ontoBranch}]%f"
  echo -n "%F{$COLOR[$transplantColor]}[${transplantBranch}]%f"
}
# }}}
# Git: Tag {{{
function oroshi_prompt_git_tag() {
  local tagName="$(git tag-current)"
  [[ $tagName = '' ]] && return

  # Check if commits have been added since last tag
  git-commit-tagged && echo -n " %F{$COLOR[orange]} $tagName" && return
  echo -n " %F{$COLOR[gray7]}炙$tagName"
}
# }}}
# Git: Remote {{{
function oroshi_prompt_git_remote() {
  local remoteName="$(git remote-current)"
  [[ $remoteName = 'origin' || $remoteName == '' ]] && return;

  echo " %F{$COLOR[yellow]} $remoteName%f"
}
# }}}
# Git: Branch {{{
function oroshi_prompt_git_branch() {
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


  local branchColor="$(oroshi_prompt_git_branch_color $branchName)"

  local remoteStatus
  remoteStatus="$(git-branch-remote-status)"
  [[ $remoteStatus = 'local_ahead' ]] && echo -n " %F{$COLOR[$branchColor]}  $branchName%f"
  [[ $remoteStatus = 'local_behind' ]] && echo -n " %F{$COLOR[$branchColor]} $branchName%f"
  [[ $remoteStatus = 'local_diverged' ]] && echo -n " %F{$COLOR[red]} $branchName%f"
  [[ $remoteStatus = 'local_never_pushed' ]] && echo -n " %F{$COLOR[$branchColor]} $branchName%f"
  [[ $remoteStatus = 'local_identical' ]] && echo -n " %F{$COLOR[$branchColor]}$branchName%f"
}
# Get the name of the color based on the name of the branch
function oroshi_prompt_git_branch_color() {
  [[ $1 == "master" ]] && echo "blue5" && return;
  [[ $1 == "main" ]] && echo "blue" && return;
  [[ $1 == "develop" ]] && echo "yellow" && return;
  [[ $1 == "heroku" ]] && echo "purple" && return;
  echo "orange"
}
# }}}
