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

  colors-load-definitions
  icons-load-definitions

  # Staged files
  if git-directory-has-staged-files; then
    OROSHI_PROMPT_PARTS[git_status]="%F{$COLORS[git-tracked]}$ICONS[git-commit]%f"
    return
  fi

  # Dirty directory
  if git-directory-is-dirty; then
    OROSHI_PROMPT_PARTS[git_status]="%F{$COLORS[git-untracked]}$ICONS[git-commit]%f"
    return
  fi

  # Clean directory
  OROSHI_PROMPT_PARTS[git_status]="%F{$COLORS[success]}$ICONS[git-commit]%f"
}
