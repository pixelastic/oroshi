# Returns a colorized string to represent a given project
# Usage:
# $ colorize-project oroshi   #
function colorize-project () {
  local projectKey="$1"

  # Read all linked variables
  local projectName=${(P)${:-PROJECT_${projectKey}_NAME}}
  local projectPath=${(P)${:-PROJECT_${projectKey}_PATH}}
  local projectBackground=${(P)${:-PROJECT_${projectKey}_BACKGROUND}}
  local projectForeground=${(P)${:-PROJECT_${projectKey}_FOREGROUND}}
  local projectIcon=${(P)${:-PROJECT_${projectKey}_ICON}}
  local projectHideNameInPrompt=${(P)${:-PROJECT_${projectKey}_HIDE_NAME_IN_PROMPT}}

  # Don't display the project name (for ~ for example)
  [[ $projectHideNameInPrompt == "1" ]] && projectName=""

  # Display the final colorized string
  local output=""
  output+="[38;5;${projectForeground}m[48;5;${projectBackground}m ${projectIcon}${projectName} [00m"
  output+="[38;5;${projectBackground}m[00m"
  echo $output
}
