# Returns the relative path (from the git root) of a given file
# Usage:
# $ git-file-path /full/path/to/repo/folder/file      # folder/file
function git-file-path() {
  local inputPath="$1"
  git ls-files --full-name $inputPath
}
