# Check if currently in a .git folder
function git-directory-is-dot-git() {
  if [[ $PWD == *\.git* ]]; then
    return 0
  fi
  return 1
}
