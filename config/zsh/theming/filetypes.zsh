# This will load FILETYPE_GROUPS and FILETYPES definitions. For example:
#
# Broad strokes definitions for whole groups of patterns
# - FILETYPE_GROUPS[scripts,patterns] // .rb,.js
# - FILETYPE_GROUPS[scripts,color] // yellow
# - FILETYPE_GROUPS[scripts,icon] // 
#
# Custom overrides for specific patterns
# - FILETYPE[.js,icon] // 
# - FILETYPE[.js,bold] // 1
function () {
  source ~/.oroshi/config/zsh/theming/filetypes-list.zsh

  # Export FILETYPES_INDEX that contains the list of all the filetypes for which
  # we have an icon and color defined
  export FILETYPES_INDEX=""

  # Export FILETYPE_{TYPE}_{KEY} environment variables:
  for key value in "${(@kv)FILETYPE_GROUPS}"; do
    [[ $key != *,patterns ]] && continue

    # Finding the default color, icon and boldness of the group
    local groupName=${key%,*}
    local groupColor=$FILETYPE_GROUPS[${groupName},color]
    local groupIcon=$FILETYPE_GROUPS[${groupName},icon]
    local groupBold=$FILETYPE_GROUPS[${groupName},bold]
    [[ $groupBold == "" ]] && groupBold="0"


    # Creating FILETYPES entries for each pattern, for example:
    # - FILETYPES_CSS_ICON
    # - FILETYPES_CSS_COLOR
    # - FILETYPES_CSS_BOLD
    local patterns=(${=value})
    for pattern in $patterns; do
      # Only assign them if they aren't already defined
      local color=${FILETYPES[${pattern},color]:-$groupColor}
      local icon=${FILETYPES[${pattern},icon]:-$groupIcon}
      local bold=${FILETYPES[${pattern},bold]:-$groupBold}

      # Export the ENV variables
      local indexName=${(U)pattern:gs/\.//}
      export FILETYPES_${indexName}_PATTERN=$pattern
      export FILETYPES_${indexName}_ICON=$icon
      export FILETYPES_${indexName}_COLOR=$COLORS[$color]
      export FILETYPES_${indexName}_BOLD=$bold
      FILETYPES_INDEX+=" $indexName"
    done
  done
}
