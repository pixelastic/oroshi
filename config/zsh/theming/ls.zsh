# ls
#
# Configure the colors used by ls (and exa) to display the various files and
# directories
function () {
  # Define the custom LS_COLORS
  LS_COLORS=""
  LS_COLORS="${LS_COLORS}:di=38;5;$COLORS[green]"     # Directory
  LS_COLORS="${LS_COLORS}:ex=4;38;5;$COLORS[purple5]" # Executable
  LS_COLORS="${LS_COLORS}:ln=34;4;$COLORS[blue6]"     # Symlink
  LS_COLORS="${LS_COLORS}:.*=38;5;$COLORS[red5]"      # Hidden files

  # Define LS_COLORS by looping through all FILETYPES_***_color
  for extension in ${=FILETYPES_INDEX}; do
    # Those are nested zsh modifiers:
    # - ${AAA:-BBB} reads AAA variables, and if empty sets BBB as the value
    # - Here, we set AAA as empty, so it jumps rights to BBB
    # - Which is converted into the string FILETYPES_XXX_YYY
    # - ${(P}CCC} reads the value of CCC and uses it as the variable name
    local pattern=${(P)${:-FILETYPES_${extension}_PATTERN}}
    local color=${(P)${:-FILETYPES_${extension}_COLOR}}
    local bold=${(P)${:-FILETYPES_${extension}_BOLD}}

    # Add to LS_COLORS
    LS_COLORS+=":*${pattern}=${bold};38;5;$color"
  done

  export LS_COLORS
}

