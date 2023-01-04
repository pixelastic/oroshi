# This will load FILETYPE_GROUPS and FILETYPES definitions. For example:
#
# Broad strokes definitions for whole groups of extensions
# - FILETYPE_GROUPS[scripts,extensions] // rb,js
# - FILETYPE_GROUPS[scripts,color] // yellow
# - FILETYPE_GROUPS[scripts,icon] // 
#
# Custom overrides for specific extensions
# - FILETYPE[js,icon] // 
# - FILETYPE[js,bold] // 1
source ~/.oroshi/config/zsh/theming/filetypes-list.zsh

# Create entries in FILETYPES for all extensions of FILETYPE_GROUPS
for key value in "${(@kv)FILETYPE_GROUPS}"; do
  [[ $key != *,extensions ]] && continue

  # Finding the default color, icon and boldness of the group
  local groupName=${key%,*}
  local color=$FILETYPE_GROUPS[${groupName},color]
  local icon=$FILETYPE_GROUPS[${groupName},icon]
  local bold=$FILETYPE_GROUPS[${groupName},bold]
  [[ $bold == "" ]] && bold="0"

  # Creating FILETYPES entries for each extension
  local extensions=(${=value})
  for extension in $extensions; do
    # Only assign them if they aren't already defined
    FILETYPES[${extension},color]=${FILETYPES[${extension},color]:-$color}
    FILETYPES[${extension},icon]=${FILETYPES[${extension},icon]:-$icon}
    FILETYPES[${extension},bold]=${FILETYPES[${extension},bold]:-$bold}
  done
done
