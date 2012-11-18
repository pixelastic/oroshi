# Make using 256 colors in zsh less painful.
# Copied from http://github.com/sykora/etc/blob/master/zsh/functions/spectrum/
typeset -Ag FX FG BG

FX=(
    reset     "%{[00m%}"
    bold      "%{[01m%}" no-bold      "%{[22m%}"
    italic    "%{[03m%}" no-italic    "%{[23m%}"
    underline "%{[04m%}" no-underline "%{[24m%}"
    blink     "%{[05m%}" no-blink     "%{[25m%}"
    reverse   "%{[07m%}" no-reverse   "%{[27m%}"
)

for color in {000..255}; do
    FG[$color]="%{[38;5;${color}m%}"
    BG[$color]="%{[48;5;${color}m%}"
done


# Default theme
# Note: The colors are based on the colors used in the vim oroshi colorscheme
typeset -A promptColorDefault
promptColorDefault=(
	username          "069" # Username color
	root              "160" # Root color
	hostname          "171" # Hostname color
	pathOwner         "035" # Prompt color of path if user is owner
	pathGroup         "203" # Prompt color of path if user is in group
	pathRestricted    "160" # Prompt color if not owner nor in group
	debug             "209" # Debug used in prompt
	
	tag               "241" # Current repo tag
	tagExact          "202" # Color for tag if we are at the exact commit
	submodule         "185" # Submodule symbol
	branchDefault     "202" # Default color for branch
	branchMaster      "035" # Color for master branch
	branchDetached    "160" # Color for detached HEAD branch

	hgClean           "035" # Color of the VCS symbol if repo up to date
	hgDirty           "160" # Color of the VCS symbol if repo modified

	gitClean          "035" # Repo is clean
	gitStaged         "171" # Files are staged, ready to be commited
	gitDirty          "160" # Repo is dirty
	gitDirtyAndStaged "203" # Repo is dirty AND files are staged

	gitFlowDevelop    "184" # develop branch
	gitFlowMaster     "069" # master branch
	gitFlowHotfix     "160" # hotfix branch
	gitFlowRelease    "028" # release branch
	gitFlowFeature    "202" # feature branch
	gitFlowBugfix     "203" # bugfix branch
)

# Merging default colors in promptColor
for key in ${(k)promptColorDefault}; do
	if [[ $promptColor[$key] = "" ]]; then;
		promptColor[$key]=$promptColorDefault[$key]
	fi
done

# Coloring manpages
export LESS_TERMCAP_md=$'\E[38;5;68m'               # Titles
export LESS_TERMCAP_us=$'\E[04;38;5;209m'           # Values
export LESS_TERMCAP_so=$'\E[01;48;5;67;38;5;233m'   # Info box
export LESS_TERMCAP_mb=$'\E[01;48;5;133;38;5;160m'  # ????
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_ue=$'\E[0m'

