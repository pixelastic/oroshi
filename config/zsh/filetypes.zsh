# FILETYPES
# This file contain definition of the various filetypes and how they should be
# handled
# ============================================================================
#

# We source the file holding our filetype definition
source ~/.oroshi/config/zsh/filetypes.db.zsh

# Creating global arrays containing the command, color and extensions bound to
# each type of file. This will be much easier having them like this to use them
# in completion functions later.
typeset -Ag O_FILETYPES_COMMAND O_FILETYPES_COLOR O_FILETYPES_EXTENSIONS

# Using the list defined above, we defined some ZSH aliases to open the
# matching extensions with the correct command.
for ft in ${(k)O_FILETYPES}; do
	# We get the command used for this filetype
	ft_command=$(echo $O_FILETYPES[$ft] | awk -F: '{ print $1 }')
	# We get the color to be used
	ft_color=$(echo $O_FILETYPES[$ft] | awk -F: '{ print $2 }')
	# And the list of extensions, as a ZSH array
	ft_extensions=$(echo $O_FILETYPES[$ft] | awk -F: '{ print $3 }')

	# We populate global arrays containing for each type of file the command,
	# color and extension list
	O_FILETYPES_COMMAND[$ft]=$ft_command
	O_FILETYPES_COLOR[$ft]=$ft_color
	O_FILETYPES_EXTENSIONS[$ft]=$ft_extensions

	# We create a -s alias for each of this extensions matching the command
	for ext in ${(s/,/)ft_extensions}; do
		alias -s $ext=$ft_command
		# Same goes for uppercase extensions
		alias -s ${ext:u}=$ft_command
	done
done
# Removing the vars so as not to pollute global scope
unset ft_command
unset ft_color
unset ft_extensions

# Use the ~/.dircolors file as a database for coloring ls output
# The file is generated on an oroshi deploy and contains the default colors
# with special colors for custom extensions as defined by the O_FILETYPES array
if [[ -r ~/.dircolors ]]; then
	eval "`dircolors -b ~/.dircolors`"
fi

