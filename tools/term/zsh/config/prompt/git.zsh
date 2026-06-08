# shellcheck disable=SC2154
# Git
# Display git-related information

# Display a colored coded git symbol
# - Green if no files were changed
# - Red if any file has been added/deleted/modified
# - Purple if files are added to the index
function oroshi-prompt-populate:git_status() {
  OROSHI_PROMPT_PARTS[git_status]=""

  # Stop if not in a git repo if in a .git/ folder
  if [[ $GIT_DIRECTORY_IS_REPOSITORY == "0" ]] || git-directory-is-dot-git; then
    OROSHI_PROMPT_PARTS[git_status]=""
    return
  fi

  # Staged files
  if git-directory-has-staged-files; then
    OROSHI_PROMPT_PARTS[git_status]="%F{$COLOR_ALIAS_GIT_TRACKED}$ICONS[git-commit]%f"
    return
  fi

  # Dirty directory
  if git-directory-is-dirty; then
    OROSHI_PROMPT_PARTS[git_status]="%F{$COLOR_ALIAS_GIT_UNTRACKED}$ICONS[git-commit]%f"
    return
  fi

  # Clean directory
  OROSHI_PROMPT_PARTS[git_status]="%F{$COLOR_ALIAS_SUCCESS}$ICONS[git-commit]%f"
}

# Display a colored branch, with icons
function oroshi-prompt-populate:git_branch() {
  OROSHI_PROMPT_PARTS[git_branch]=""
  (($GIT_DIRECTORY_IS_REPOSITORY)) || return
  # In worktrees, we display the branch on the left
  (($GIT_DIRECTORY_IS_WORKTREE)) && return

  OROSHI_PROMPT_PARTS[git_branch]="$(git-branch-colorize --with-icon --zsh)"
}

# Display the most relevant git tag
function oroshi-prompt-populate:git_tag() {
  OROSHI_PROMPT_PARTS[git_tag]=""
  (($GIT_DIRECTORY_IS_REPOSITORY)) || return

  OROSHI_PROMPT_PARTS[git_tag]="$(git-tag-colorize --with-icon --zsh)"
}

# Display the current remote
function oroshi-prompt-populate:git_remote() {
  OROSHI_PROMPT_PARTS[git_remote]=""
  (($GIT_DIRECTORY_IS_REPOSITORY)) || return

  local currentRemoteName="$(git-remote-current)"
  [[ $currentRemoteName == 'origin' ]] && return

  OROSHI_PROMPT_PARTS[git_remote]="$(git-remote-colorize --with-icon --zsh)"
}

# Display ahead/behind counts vs main (right prompt, asynchronous)
function oroshi-prompt-populate:git_worktree_distance() {
  OROSHI_PROMPT_PARTS[git_worktree_distance]=""
  (($GIT_DIRECTORY_IS_REPOSITORY)) || return
  (($GIT_DIRECTORY_IS_WORKTREE)) || return

  local iconAhead="$ICONS[git-ahead]"
  local iconBehind="$ICONS[git-behind]"

  # Output format: "ahead N, behind M" — empty on failure
  local distanceOutput="$(git-worktree-distance)"
  [[ "$distanceOutput" == "" ]] && return

  local aheadStr="${distanceOutput##ahead }"
  local ahead="${aheadStr%%,*}"
  local behind="${distanceOutput##*, behind }"

  # Both 0 means in sync, nothing to display
  [[ "$ahead" == "0" && "$behind" == "0" ]] && return

  local result=""
  [[ "$ahead" != "0" ]] && result+="%F{$COLOR_ALIAS_GIT_AHEAD}${ahead}${iconAhead}%f"
  [[ "$behind" != "0" ]] && [[ "$result" != "" ]] && result+=" "
  [[ "$behind" != "0" ]] && result+="%F{$COLOR_ALIAS_GIT_BEHIND}${behind}${iconBehind}%f"

  OROSHI_PROMPT_PARTS[git_worktree_distance]="$result"
}

# Check if in a submodule
function oroshi-prompt-populate:git_is_submodule() {
  OROSHI_PROMPT_PARTS[git_is_submodule]=""
  (($GIT_DIRECTORY_IS_REPOSITORY)) || return

  git-is-submodule || return

  OROSHI_PROMPT_PARTS[git_is_submodule]="%F{$COLOR_ALIAS_GIT_SUBMODULE}$ICONS[git-submodule] %f"
}

# Check if has stashes
function oroshi-prompt-populate:git_has_stash() {
  OROSHI_PROMPT_PARTS[git_has_stash]=""
  (($GIT_DIRECTORY_IS_REPOSITORY)) || return

  git-stash-exists || return

  OROSHI_PROMPT_PARTS[git_has_stash]="%F{$COLOR_ALIAS_GIT_STASH}$ICONS[git-stash] %f"
}

# Check if rebase is in progress
function oroshi-prompt-populate:git_rebase_in_progress() {
  OROSHI_PROMPT_PARTS[git_rebase_in_progress]=""

  git-rebase-in-progress || return

  OROSHI_PROMPT_PARTS[git_rebase_in_progress]="%F{$COLOR_ALIAS_GIT_REBASE}$ICONS[git-rebase] %f"
}

# Display the current state of the rebase:
# - How many steps are there
# - commitId of the current commit being rebased
function oroshi-prompt-populate:git_rebase_status() {
  OROSHI_PROMPT_PARTS[git_rebase_status]=""
  (($GIT_DIRECTORY_IS_REPOSITORY)) || return
  git-rebase-in-progress || return

  local rawInfo="$(git-rebase-info-raw)"
  [[ "$rawInfo" == "" ]] && return

  local fields=(${(@ps/▮/)rawInfo})
  local stepCurrent=$fields[1]
  local stepMax=$fields[2]
  local headName=$fields[3]
  local onto=$fields[4]

  headName=${headName:11}
  onto=${onto:0:8}

  local headNameColor="$(git-branch-color $headName)"

  OROSHI_PROMPT_PARTS[git_rebase_status]="%B%F{$COLOR_ALIAS_GIT_REBASE}$ICONS[git-rebase] ${stepCurrent}/${stepMax}%f%b %F{$headNameColor}${headName}%f:%F{$COLOR_ALIAS_GIT_COMMIT}${onto}%f"
}

# Returns the number of currently opened issues
function oroshi-prompt-populate:git_issues_github() {
  OROSHI_PROMPT_PARTS[git_issues_github]=""
  (($GIT_DIRECTORY_IS_REPOSITORY)) || return
  (($GIT_DIRECTORY_IS_WORKTREE)) && return
  git-directory-is-github || return

  # No GITHUB_TOKEN
  if [[ $GITHUB_TOKEN_READONLY == "" ]]; then
    OROSHI_PROMPT_PARTS[git_issues_github]="%F{$COLOR_ALIAS_ERROR}$ICONS[git-issue] %f"
    return
  fi

  local projectName="$(git-github-project)"
  local cacheFolderPath="${OROSHI_TMP_FOLDER}/github/${projectName}"
  mkdir -p $cacheFolderPath

  local issuesCacheFile="${cacheFolderPath}/issues"
  local cacheDuration=1440 # In minutes

  # We update the count if file does not exist, or too old
  if [[ ! -r $issuesCacheFile ]] || is-older $issuesCacheFile $cacheDuration; then
    git-issue-count >$issuesCacheFile
  fi

  local issueCount="$(<$issuesCacheFile)"
  if [[ $issueCount != "0" ]]; then
    OROSHI_PROMPT_PARTS[git_issues_github]="%F{$COLOR_ALIAS_GIT_ISSUE}$ICONS[git-issue] ${issueCount}%f"
  fi
}

# Returns the number of currently opened pullrequests
function oroshi-prompt-populate:git_pullrequests() {
  OROSHI_PROMPT_PARTS[git_pullrequests]=""
  (($GIT_DIRECTORY_IS_REPOSITORY)) || return
  git-directory-is-github || return

  # No GITHUB_TOKEN
  if [[ $GITHUB_TOKEN_READONLY == "" ]]; then
    OROSHI_PROMPT_PARTS[git_pullrequests]="%F{$COLOR_ALIAS_ERROR}$ICONS[git-pr] %f"
    return
  fi

  local projectName="$(git-github-project)"
  local cacheFolderPath="${OROSHI_TMP_FOLDER}/github/${projectName}"
  mkdir -p $cacheFolderPath

  local pullrequestsCacheFile="${cacheFolderPath}/pullrequests"
  local cacheDuration=1440 # In minutes

  # We update the count if file does not exist, or too old
  if [[ ! -r $pullrequestsCacheFile ]] || is-older $pullrequestsCacheFile $cacheDuration; then
    git-pullrequest-count >$pullrequestsCacheFile
  fi

  local pullrequestCount="$(<$pullrequestsCacheFile)"
  if [[ $pullrequestCount != "0" ]]; then
    OROSHI_PROMPT_PARTS[git_pullrequests]="%F{$COLOR_ALIAS_GIT_PULLREQUEST}$ICONS[git-pr] ${pullrequestCount}%f"
  fi
}

# Shows plan progress when inside a plan worktree
function oroshi-prompt-populate:git_plan_progress() {
  OROSHI_PROMPT_PARTS[git_plan_progress]=""
  (($GIT_DIRECTORY_IS_REPOSITORY)) || return
  (($GIT_DIRECTORY_IS_WORKTREE)) || return

  # No plan in this worktree → nothing to show
  git-worktree-has-plan || return

  local icon="$ICONS[git-issue] "

  local progress="$(plan-progress)"
  # Empty output means plan-progress failed (malformed JSON, empty array, etc.)
  if [[ "$progress" == "" ]]; then
    OROSHI_PROMPT_PARTS[git_plan_progress]="%F{$COLOR_ALIAS_ERROR}${icon}%f"
    return
  fi

  local fields=(${(@ps/▮/)progress})
  local done=$fields[1]
  local total=$fields[2]

  local color="$COLOR_ALIAS_GIT_ISSUE"
  [[ "$done" == "$total" ]] && color="$COLOR_ALIAS_SUCCESS"

  OROSHI_PROMPT_PARTS[git_plan_progress]="%F{$color}${icon}${done}/${total}%f"
}
# }}}
