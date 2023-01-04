# ls
#
# Configure the colors used by ls (and exa) to display the various files and
# directories

# Define the custom LS_COLORS
LS_COLORS=""
LS_COLORS="${LS_COLORS}:di=38;5;$COLORS[green]"     # Directory
LS_COLORS="${LS_COLORS}:ex=4;38;5;$COLORS[purple5]" # Executable
LS_COLORS="${LS_COLORS}:ln=34;4;$COLORS[blue6]"     # Symlink
LS_COLORS="${LS_COLORS}:.*=38;5;$COLORS[red5]"      # Hidden files

# Define LS_COLORS by looping through all FILETYPES
for key value in "${(@kv)FILETYPES}"; do
  [[ $key != *,color ]] && continue

  # Finding the color and boldness of the extension
  local extension=${key%,*}
  local color=$COLORS[$value]
  local bold=$FILETYPES[${extension},bold]

  # Add to LS_COLORS
  LS_COLORS+=":*${extension}=${bold};38;5;$color"
done

export LS_COLORS
