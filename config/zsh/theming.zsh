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
  username              "069"
  hostname              "171"
  pathWritable          "035"
  pathNotWritable       "160"
  lastCommandFailed     "160"
  rubyVersion           "203"


  tag                   "241"
  submodule             "136"
  rebase                "160"
  stash                 "171"
  branchDefault         "202"
  branchDetached        "160"
  branchDevelop         "184"
  branchFix             "203"
  branchGhPages         "024"
  branchGone            "160"
  branchHeroku          "141"
  branchMaster          "069"
  branchRelease         "171"
  remoteDefault         "241"
  remoteHeroku          "141"
  remoteGithub          "024"
  remoteUpstream        "069"
  remoteAlgolia         "067"
  repoClean             "035"
  repoStaged            "171"
  repoDirty             "160"

  commandText           "252"
  commandCommand        "028"
  commandAlias          "108"
  commandKeyword        "203"
  commandError          "160"
  commandString         "067"
  commandArgument       "209"
  commandPath           "252"
  commandPathIncomplete "249"
  commandSeparator      "136"

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

