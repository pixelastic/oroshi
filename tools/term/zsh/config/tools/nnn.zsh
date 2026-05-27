# nnn
# A terminal file explorer
# https://github.com/jarun/nnn
#
# Notes:
# Preview doesn't work really well. It is only applied on demand (but can
# probably be automatically enabled with the right option, something like "-P
# p").
# The main problem is that it opens the preview in a kitty split pane, so it
# doesn't work when I'm already in a full-screen kitty pane. fzf has its own
# preview builtin, so it works correctly with kitty.
#
# I currently (December 2023) think it can be useful for quickly navigating in
# folders instead of cd/ls, or to apply commands on files directly from it. But
# probably the same could be achieved in a custom fzf.

# Todo:
# - icons
# - multiselect and add to terminal
# - fzf search in current directory
# - ctrl-c to quit
# - Different color for filetypes?
#
#
# Colors {{{
function oroshi_nnn_colors() {
	local NNN_BLOCK_DEVICE="00"
	local NNN_CHAR_DEVICE="00"
	local NNN_DIRECTORY="${(l:2::0:)COLOR_ALIAS_DIRECTORY}"
	local NNN_EXECUTABLE="${(l:2::0:)COLOR_ALIAS_EXECUTABLE}"
	local NNN_REGULAR="00"
	local NNN_HARD_LINK="00"
	local NNN_SYMBOLIC_LINK="${(l:2::0:)COLOR_ALIAS_LINK}"
	local NNN_MISSING_OR_FILE_DETAILS="${(l:2::0:)COLOR_ALIAS_ERROR}"
	local NNN_ORPHANED_SYMBOLIC_LINK="${(l:2::0:)COLOR_ALIAS_ERROR}"
	local NNN_FIFO="00"
	local NNN_SOCKET="00"
	local NNN_UNKNOWN="00"

	export NNN_FCOLORS="${NNN_BLOCK_DEVICE}${NNN_CHAR_DEVICE}${NNN_DIRECTORY}${NNN_EXECUTABLE}${NNN_REGULAR}${NNN_HARD_LINK}${NNN_SYMBOLIC_LINK}${NNN_MISSING_OR_FILE_DETAILS}${NNN_ORPHANED_SYMBOLIC_LINK}${NNN_FIFO}${NNN_SOCKET}${NNN_UNKNOWN}"
}
oroshi_nnn_colors
unfunction oroshi_nnn_colors
# }}}
#
# Options {{{
# Automatically start nnn with some default arguments
function oroshi_nnn_options() {
	local _NNN_OPTS=""
	_NNN_OPTS+="a" # auto NNN_FIFO per instance
	_NNN_OPTS+="P" # load plugins

	export NNN_OPTS="${_NNN_OPTS}"

}
oroshi_nnn_options
unfunction oroshi_nnn_options
# }}}

export NNN_PLUG="p:preview-tui"

