# Returns the number of currently opened issues
function oroshi-prompt-populate:git_issues_github() {
  OROSHI_PROMPT_PARTS[git_issues_github]=""
  (($GIT_DIRECTORY_IS_REPOSITORY)) || return
  (($GIT_DIRECTORY_IS_WORKTREE)) && return
  git-directory-is-github || return

  colors-load-definitions
  icons-load-definitions

  # No GITHUB_TOKEN
  if [[ $GITHUB_TOKEN_READONLY == "" ]]; then
    OROSHI_PROMPT_PARTS[git_issues_github]="%F{$COLORS[error]}$ICONS[git-issue] %f"
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
    OROSHI_PROMPT_PARTS[git_issues_github]="%F{$COLORS[git-issue]}$ICONS[git-issue] ${issueCount}%f"
  fi
}
