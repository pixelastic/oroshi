# Given a filepath, will return the name of the project it belongs to
# To be used with $PROJECT_XXX_*** variables
# Usage:
# $ project-by-path               # Returns name of current folder project
# $ project-by-path ~/local/www   # Returns name of specific folder project
function project-by-path () {
  local pathToCheck="$1"
  [[ "$pathToCheck" == "" ]] && pathToCheck="$PWD/"

  # Replace home path with ~
  pathToCheck=$(print -D $pathToCheck)


  for projectKey in ${=PROJECTS_INDEX_BY_PATH}; do
    local projectPath=${(P)${:-PROJECT_${projectKey}_PATH}}
    [[ $pathToCheck != $projectPath* ]] && continue
    echo $projectKey
    break
  done
}
