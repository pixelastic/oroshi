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

  tag                "241" # Color of the current tag
  tagExact           "202" # Color of the exact current tag
  submodule          "136" # Color of the submodule symbol
  rebase             "160" # Color of the rebase symbol
  stash              "160" # Color of the stash
  branchDefault      "202" # Default color for branches
  branchDetached     "160" # Color for detached HEAD branch
  branchMaster       "069" # Color for master branch
  branchDevelop      "184" # Color of develop branch
  branchBugfix       "203" # Color of bugfix branch
  branchTest         "136" # Color of test branch
  branchFeature      "202" # Color of feature branch
  branchReview       "028" # Color of review branch
  branchPerf         "141" # Color of perf branch
  branchGhPages      "024" # Color of gh-pages branch
  repoClean          "035" # Color of clean repo
  repoStaged         "171" # Color if files are staged, ready to be commited
  repoDirty          "160" # Color if repo is dirty
  repoDirtyAndStaged "203" # Color if repo is dirty AND files are staged
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

