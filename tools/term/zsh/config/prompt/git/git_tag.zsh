# Display the most relevant git tag
function oroshi-prompt-populate:git_tag() {
  OROSHI_PROMPT_PARTS[git_tag]=""
  (($GIT_DIRECTORY_IS_REPOSITORY)) || return

  OROSHI_PROMPT_PARTS[git_tag]="$(git-tag-colorize --with-icon --zsh)"
}
