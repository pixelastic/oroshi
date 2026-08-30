# Display the current remote
function oroshi-prompt-populate:git_remote() {
  OROSHI_PROMPT_PARTS[git_remote]=""
  (($GIT_DIRECTORY_IS_REPOSITORY)) || return

  local currentRemoteName="$(git-remote-current)"
  [[ $currentRemoteName == 'origin' ]] && return

  OROSHI_PROMPT_PARTS[git_remote]="$(git-remote-colorize --with-icon --zsh)"
}
