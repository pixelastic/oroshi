# ls
#
# Configure the colors used by ls and exa to display the various files and
# directories

function oroshi_tools_ls() {
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
	LS_COLORS_SIMPLE+=":ex=4;38;5;$COLORS[executable]" # Executable
	LS_COLORS_SIMPLE+=":ln=34;4;$COLORS[link]"         # Symlink

	# Other known LS_COLORS fields, potentially used by the completion styling system
	# LS_COLORS_SIMPLE+=":st=1;38;5;$COLORS[red]"     # file with sticky bit set
	# LS_COLORS_SIMPLE+=":pi=1;38;5;$COLORS[green]"   # fifo file
	# LS_COLORS_SIMPLE+=":mh=1;38;5;$COLORS[green]"   # file with 'b' set (for access control lists)
	# LS_COLORS_SIMPLE+=":rs=1;38;5;$COLORS[emerald]" # reset to no color code
	# LS_COLORS_SIMPLE+=":so=1;38;5;$COLORS[yellow]"  # socket file
	# LS_COLORS_SIMPLE+=":cl=1;38;5;$COLORS[yellow]"  # file with 'c' set (for access control lists)
	# LS_COLORS_SIMPLE+=":bd=1;38;5;$COLORS[blue]"    # block (buffered) special file
	# LS_COLORS_SIMPLE+=":tw=1;38;5;$COLORS[blue]"    # directory that is sticky and other-writable (o+w) (+t,+w)
	# LS_COLORS_SIMPLE+=":st=1;38;5;$COLORS[cyan]"    # directory with the sticky bit set (+t)
	# LS_COLORS_SIMPLE+=":or=1;38;5;$COLORS[cyan]"    # symbolic link pointing to a non-existent file (orphan)
	# LS_COLORS_SIMPLE+=":ca=1;38;5;$COLORS[sky]"     # file with capability
	# LS_COLORS_SIMPLE+=":sg=1;38;5;$COLORS[teal]"    # file with setgid bit set
	# LS_COLORS_SIMPLE+=":su=1;38;5;$COLORS[violet]"  # file with setuid bit set
	# LS_COLORS_SIMPLE+=":cd=1;38;5;$COLORS[purple]"  # character (unbuffered) special file
	# LS_COLORS_SIMPLE+=":mi=1;38;5;$COLORS[orange]"  # non-existent file pointed to by a symbolic link (visible when you type ls -l)
	# LS_COLORS_SIMPLE+=":tw=1;38;5;$COLORS[amber]"   # sticky other-writable (o+w) file; and sticky other-writable directory
	

	# Enhance LS_COLORS by looping through all FILETYPES_***_color
	# Note: It isn't possible to color all hidden files (.*) with LS_COLORS
	# Instead, we have a known list of the most common files defined in
	# filetypes-list.zsh
	LS_COLORS=$LS_COLORS_SIMPLE
	for extension in ${=FILETYPES_INDEX}; do
		# Those are nested zsh modifiers:
		# - ${AAA:-BBB} reads AAA variables, and if empty sets BBB as the value
		# - Here, we set AAA as empty, so it jumps rights to BBB
		# - Which is converted into the string FILETYPES_XXX_YYY
		# - ${(P}CCC} reads the value of CCC and uses it as the variable name
		local pattern=${(P)${:-FILETYPE_${extension}_PATTERN}}
		local color=${(P)${:-FILETYPE_${extension}_COLOR}}
		local bold=${(P)${:-FILETYPE_${extension}_BOLD}}

		LS_COLORS="${LS_COLORS}:${pattern}=${bold};38;5;$color"
	done

	# Export the vars, to make them available to all other scripts
	export LS_COLORS
	export LS_COLORS_SIMPLE
}
oroshi_tools_ls
unfunction oroshi_tools_ls
