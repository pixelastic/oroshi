# Creating PROJECT entries, for example:
# - PROJECT_ABERLAAS_NAME
# - PROJECT_ABERLAAS_PATH
# - PROJECT_ABERLAAS_ICON
# - PROJECT_ABERLAAS_BACKGROUND
# - PROJECT_ABERLAAS_BACKGROUND_HEXA
# - PROJECT_ABERLAAS_FOREGROUND
# - PROJECT_ABERLAAS_FOREGROUND_HEXA
# - PROJECT_ABERLAAS_HIDE_NAME_IN_PROMPT
function () {
  # This will load PROJECTS definitions. For example:
  #
  # - PROJECTS[aberlaas,background]="YELLOW_7"
  # - PROJECTS[aberlaas,icon]=" "
  # - PROJECTS[aberlaas,path]="~/local/www/projects/aberlaas/"
  # - PROJECTS[aberlaas,text]="GRAY_9"
  source ~/.oroshi/config/zsh/theming/projects-list.zsh

  # We'll keep a list of all projects, and a list of all paths
  # - PROJECTS_INDEX will contains an alphabetical list of all projects
  # - PROJECTS_INDEX_BY_PATH will contains the same list, ordered by path
  # For now, we gather them in an array, and we'll sort them one we have them
  # all
  local projectsIndex=()
  declare -gA projectsIndexByPath
  projectsIndexByPath=()

  # Export PROJECT_{TYPE}_{KEY} environment variables:
  for key value in "${(@kv)PROJECTS}"; do
    [[ $key != *,icon ]] && continue

    # Finding the values
    # Project name: aberlaas
    local projectName=${key%,*}
    # Capitalized project name: ABERLAAS
    local projectKey=${(U)projectName:gs/-/_/}
    # Background colors
    local backgroundColorName=$PROJECTS[${projectName},background]
    local backgroundColorTerm=${(P)${:-COLOR_${backgroundColorName}}}
    local backgroundColorHexa=${(P)${:-COLOR_${backgroundColorName}_HEXA}}
    # Text colors
    local textColorName=$PROJECTS[${projectName},text]
    local textColorTerm=${(P)${:-COLOR_${textColorName}}}
    local textColorHexa=${(P)${:-COLOR_${textColorName}_HEXA}}
    # Icon
    local icon=$PROJECTS[${projectName},icon]
    # Path
    local projectPath=$PROJECTS[${projectName},path]
    # Should hide the name in prompt?
    local hideNameInPrompt=$PROJECTS[${projectName},hideNameInPrompt]
    [[ $hideNameInPrompt == "" ]] && hideNameInPrompt="0"

    # Creating PROJECT entries
    export PROJECT_${projectKey}_NAME=$projectName
    export PROJECT_${projectKey}_PATH=$projectPath
    export PROJECT_${projectKey}_ICON=$icon
    export PROJECT_${projectKey}_BACKGROUND=$backgroundColorTerm
    export PROJECT_${projectKey}_BACKGROUND_HEXA=$backgroundColorHexa
    export PROJECT_${projectKey}_FOREGROUND=$textColorTerm
    export PROJECT_${projectKey}_FOREGROUND_HEXA=$textColorHexa
    export PROJECT_${projectKey}_HIDE_NAME_IN_PROMPT=$hideNameInPrompt

    # Building the indices
    projectsIndex+=($projectKey)
    if [[ $projectPath != "" ]]; then
      projectsIndexByPath[$projectPath]=$projectKey
    fi
  done

  # Alphabetical list of all projects
  export PROJECTS_INDEX=""
  for projectKey in ${(o)projectsIndex}; do
    PROJECTS_INDEX+=" $projectKey"
  done

  # List of all projects, ordered by path, from specific to generic
  export PROJECTS_INDEX_BY_PATH=""
  for projectPath in ${(kO)projectsIndexByPath}; do
    local projectKey=$projectsIndexByPath[$projectPath]
    PROJECTS_INDEX_BY_PATH+=" $projectKey"
  done

}
