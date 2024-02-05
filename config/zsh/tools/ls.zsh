# ls
#
# Configure the colors used by ls (and exa) to display the various files and
# directories

function oroshi_tools_ls() {
	# Define the custom LS_COLORS
	LS_COLORS="di=38;5;$COLOR_ALIAS_DIRECTORY"      # Directory
	LS_COLORS+=":ow=38;5;$COLOR_ALIAS_DIRECTORY"    # Directory writable by others
	LS_COLORS+=":ex=4;38;5;$COLOR_ALIAS_EXECUTABLE" # Executable
	LS_COLORS+=":ln=34;4;$COLOR_ALIAS_LINK"         # Symlink

	# Other known LS_COLORS fields, potentially used by the completion styling system
	# LS_COLORS+=":st=1;38;5;$COLOR_RED"     # file with sticky bit set
	# LS_COLORS+=":pi=1;38;5;$COLOR_GREEN"   # fifo file
	# LS_COLORS+=":mh=1;38;5;$COLOR_GREEN"   # file with 'b' set (for access control lists)
	# LS_COLORS+=":rs=1;38;5;$COLOR_EMERALD" # reset to no color code
	# LS_COLORS+=":so=1;38;5;$COLOR_YELLOW"  # socket file
	# LS_COLORS+=":cl=1;38;5;$COLOR_YELLOW"  # file with 'c' set (for access control lists)
	# LS_COLORS+=":bd=1;38;5;$COLOR_BLUE"    # block (buffered) special file
	# LS_COLORS+=":tw=1;38;5;$COLOR_BLUE"    # directory that is sticky and other-writable (o+w) (+t,+w)
	# LS_COLORS+=":st=1;38;5;$COLOR_CYAN"    # directory with the sticky bit set (+t)
	# LS_COLORS+=":or=1;38;5;$COLOR_CYAN"    # symbolic link pointing to a non-existent file (orphan)
	# LS_COLORS+=":ca=1;38;5;$COLOR_SKY"     # file with capability
	# LS_COLORS+=":sg=1;38;5;$COLOR_TEAL"    # file with setgid bit set
	# LS_COLORS+=":su=1;38;5;$COLOR_VIOLET"  # file with setuid bit set
	# LS_COLORS+=":cd=1;38;5;$COLOR_PURPLE"  # character (unbuffered) special file
	# LS_COLORS+=":mi=1;38;5;$COLOR_ORANGE"  # non-existent file pointed to by a symbolic link (visible when you type ls -l)
	# LS_COLORS+=":tw=1;38;5;$COLOR_AMBER"   # sticky other-writable (o+w) file; and sticky other-writable directory

	export LS_COLORS
}
oroshi_tools_ls
unfunction oroshi_tools_ls
