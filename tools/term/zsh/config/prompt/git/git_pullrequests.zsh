# Returns the number of currently opened pullrequests
function oroshi-prompt-populate:git_pullrequests() {
  OROSHI_PROMPT_PARTS[git_pullrequests]=""
  (($GIT_DIRECTORY_IS_REPOSITORY)) || return
  git-directory-is-github || return

  colors-load-definitions
  icons-load-definitions

  # No GITHUB_TOKEN
  if [[ $GITHUB_TOKEN_READONLY == "" ]]; then
    OROSHI_PROMPT_PARTS[git_pullrequests]="%F{$COLORS[error]}$ICONS[git-pr] %f"
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
    local prStatus="%F{$COLORS[git-pullrequest]}$ICONS[git-pr] ${pullrequestCount}%f"
    OROSHI_PROMPT_PARTS[git_pullrequests]="$prStatus"
  fi
}
