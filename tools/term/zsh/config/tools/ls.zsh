# ls
#
# Configure the colors used by ls and exa to display the various files and
# directories

function oroshi_tools_ls() {
	colors-load-definitions
	filetypes-load-definitions

	# We define two versions of LS_COLORS.
	#
	# The default one, LS_COLORS, is used by different tools, like exa and zsh
	# completion system. It uses a more advanced matching system on filetype
	# extensions, that is not recognized by default ls.
	#
	# The simpler one, LS_COLORS_SIMPLE, only contains default definition, not the
	# advanced filetype matching, and will be used on demand when we fallback to
	# ls when exa fails.

	# Define the custom LS_COLORS
	LS_COLORS_SIMPLE="di=38;5;$COLORS[directory]"      # Directory
	LS_COLORS_SIMPLE+=":ow=38;5;$COLORS[directory]"    # Directory writable by others
	LS_COLORS_SIMPLE+=":ex=38;5;$COLORS[executable]"   # Executable
	LS_COLORS_SIMPLE+=":ln=34;4;$COLORS[link]"         # Symlink
	LS_COLORS_SIMPLE+=":or=1;38;5;$COLORS[error]"      # Broken symlink

	# Other known LS_COLORS fields, potentially used by the completion styling system
	LS_COLORS_SIMPLE+=":st=1;38;5;$COLORS[unknown]" # file with sticky bit set
	LS_COLORS_SIMPLE+=":pi=1;38;5;$COLORS[unknown]" # fifo file
	LS_COLORS_SIMPLE+=":mh=1;38;5;$COLORS[unknown]" # file with 'b' set (for access control lists)
	LS_COLORS_SIMPLE+=":rs=1;38;5;$COLORS[unknown]" # reset to no color code
	LS_COLORS_SIMPLE+=":so=1;38;5;$COLORS[unknown]" # socket file
	LS_COLORS_SIMPLE+=":cl=1;38;5;$COLORS[unknown]" # file with 'c' set (for access control lists)
	LS_COLORS_SIMPLE+=":bd=1;38;5;$COLORS[unknown]" # block (buffered) special file
	LS_COLORS_SIMPLE+=":tw=1;38;5;$COLORS[unknown]" # directory that is sticky and other-writable
	LS_COLORS_SIMPLE+=":st=1;38;5;$COLORS[unknown]" # directory with the sticky bit set (+t)
	LS_COLORS_SIMPLE+=":ca=1;38;5;$COLORS[unknown]" # file with capability
	LS_COLORS_SIMPLE+=":sg=1;38;5;$COLORS[unknown]" # file with setgid bit set
	LS_COLORS_SIMPLE+=":su=1;38;5;$COLORS[unknown]" # file with setuid bit set
	LS_COLORS_SIMPLE+=":cd=1;38;5;$COLORS[unknown]" # character (unbuffered) special file
	LS_COLORS_SIMPLE+=":mi=1;38;5;$COLORS[unknown]" # non-existent file pointed to by a symbolic link
	LS_COLORS_SIMPLE+=":tw=1;38;5;$COLORS[unknown]" # sticky other-writable (o+w) file

	# Enhance LS_COLORS by looping through all FILETYPES entries that have a :pattern key
	# Note: It isn't possible to color all hidden files (.*) with LS_COLORS
	# Instead, we have a known list of the most common files defined in filetypes.json
	LS_COLORS=$LS_COLORS_SIMPLE
	for key in ${(k)FILETYPES}; do
		[[ $key != *:pattern ]] && continue
		local ext=${key%:pattern}
		local pattern=$FILETYPES[$key]
		local color=$FILETYPES[${ext}:color]
		local bold=$FILETYPES[${ext}:bold]
		LS_COLORS="${LS_COLORS}:${pattern}=${bold};38;5;$color"
	done

	# Export the vars, to make them available to all other scripts
	export LS_COLORS
	export LS_COLORS_SIMPLE
}
oroshi_tools_ls
unfunction oroshi_tools_ls
