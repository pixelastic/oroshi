local DEBUG_STARTTIME=$(($(date +%s%N)/1000000))

# We source the file holding our filetype definition
source ~/.oroshi/config/zsh/filetypes.db.zsh

# Creating global arrays containing the command, color and extensions bound to
# each type of file. This will be much easier having them like this to use them
# in completion functions later.
typeset -Ag O_FILETYPES_COMMAND O_FILETYPES_COLOR O_FILETYPES_EXTENSIONS

# Use the ~/.dircolors file as a database for coloring ls output
# The file is generated on an oroshi deploy and contains the default colors
# with special colors for custom extensions as defined by the O_FILETYPES array
if [[ -r ~/.dircolors ]]; then
	eval "`dircolors -b ~/.dircolors`"
fi

local DEBUG_ENDTIME=$(($(date +%s%N)/1000000))
[[ $ZSH_DEBUG == 1 ]] && echo "[debug]: ${0:t}: $(($DEBUG_ENDTIME - $DEBUG_STARTTIME))ms"
