# We'll load the COLORS_, PROJECTS_ and FILETYPES_ environment variables from
# static files. If those files do not yet exist, we generate them.
function oroshi_theming_index() {
  local colorsDefinitionPath=$OROSHI_ROOT/tools/term/zsh/config/theming/env/colors.zsh
  local colorsGeneratePath=$OROSHI_ROOT/tools/term/zsh/config/theming/src/env-generate-colors

  local filetypesDefinitionPath=$OROSHI_ROOT/tools/term/zsh/config/theming/env/filetypes.zsh
  local filetypesGeneratePath=$OROSHI_ROOT/tools/term/zsh/config/theming/src/env-generate-filetypes

  function oroshi_theming_colors() {
    [[ ! -r $colorsDefinitionPath ]] && $colorsGeneratePath
    source $colorsDefinitionPath
    colors-load-definitions || true
  }
  oroshi_theming_colors && unfunction oroshi_theming_colors

  function oroshi_theming_filetypes() {
    [[ ! -r $filetypesDefinitionPath ]] && $filetypesGeneratePath
    source $filetypesDefinitionPath
  }
  oroshi_theming_filetypes && unfunction oroshi_theming_filetypes

  local iconsDefinitionPath=$OROSHI_ROOT/tools/term/zsh/config/theming/icons.zsh

  function oroshi_theming_icons() {
    source $iconsDefinitionPath
  }
  oroshi_theming_icons && unfunction oroshi_theming_icons
}
oroshi_theming_index
unfunction oroshi_theming_index
