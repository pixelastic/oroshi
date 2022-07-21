declare -gA PROJECTS
PROJECTS=()
source ~/.oroshi/config/zsh/theming/projects-list.zsh

# This associative array will match each project path with the project slug
declare -gA PROJECT_SLUG_BY_PATH
PROJECT_SLUG_BY_PATH=()

# We will now create custom PROJECT_* variables that will let us access specific
# metadata of a project more easily.
declare -gA PROJECT_BACKGROUND 
PROJECT_BACKGROUND=()
declare -gA PROJECT_ICON 
PROJECT_ICON=()
declare -gA PROJECT_TEXT 
PROJECT_TEXT=()
declare -gA PROJECT_HIDE_NAME_IN_PROMPT
PROJECT_HIDE_NAME_IN_PROMPT=()

for key value in "${(@kv)PROJECTS}"; do
  # Our loop will iterate over all project keys, but we're only interested into
  # one key per project. As all projects have at least an icon, this is the one
  # we'll keep.
  [[ $key != *,icon ]] && continue

  local projectSlug=${key%,*}

  # Saving the path in PROJECT_SLUG_BY_PATH so we can find the project from the
  # path
  local projectPath=$PROJECTS[${projectSlug},path]
  PROJECT_SLUG_BY_PATH[$projectPath]=$projectSlug

  # Saving the other metadata so we can access them from the project slug
  PROJECT_BACKGROUND[$projectSlug]=$PROJECTS[${projectSlug},background]
  PROJECT_TEXT[$projectSlug]=$PROJECTS[${projectSlug},text]
  PROJECT_ICON[$projectSlug]=$PROJECTS[${projectSlug},icon]
  PROJECT_HIDE_NAME_IN_PROMPT[$projectSlug]=$PROJECTS[${projectSlug},hideNameInPrompt]
done
