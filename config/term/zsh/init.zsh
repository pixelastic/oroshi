# Shell initialization actions that run on startup

# Move out of .git/ directory if shell started inside one
if [[ "${PWD}/" == *.git/* ]]; then
  cd "$(git-directory-root)" || return
fi
