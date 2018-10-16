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
  pythonVersion         "108"
  nodeVersion           "028"
  nodeVersionError      "160"


  tag                   "241"
  submodule             "136"
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
  rebaseTrunk           "241"
  rebaseInProgress      "160"
  remoteDefault         "241"
  remoteHeroku          "141"
  remoteGithub          "024"
  remotePixelastic      "069"
  remoteUpstream        "069"
  remoteAlgolia         "067"
  repoClean             "035"
  repoStaged            "171"
  repoDirty             "196"

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

# Coloring bat
export BAT_THEME="TwoDark"

# Coloring exa
export EXA_COLORS=""
export EXA_COLORS="${EXA_COLORS}:xx=38;5;237" # Punctuation

export EXA_COLORS="${EXA_COLORS}:ur=38;5;67" # User read
export EXA_COLORS="${EXA_COLORS}:uw=38;5;67" # User write
export EXA_COLORS="${EXA_COLORS}:ux=4;38;5;67" # User execute

export EXA_COLORS="${EXA_COLORS}:gr=38;5;28" # Group read
export EXA_COLORS="${EXA_COLORS}:gw=38;5;28" # Group write
export EXA_COLORS="${EXA_COLORS}:gx=4;38;5;28" # Group execute

export EXA_COLORS="${EXA_COLORS}:tr=38;5;241" # Other read
export EXA_COLORS="${EXA_COLORS}:tw=38;5;241" # Other write
export EXA_COLORS="${EXA_COLORS}:tx=4;38;5;241" # Other execute

export EXA_COLORS="${EXA_COLORS}:sn=38;5;209" # Size
export EXA_COLORS="${EXA_COLORS}:sb=38;5;209" # Size unit

export EXA_COLORS="${EXA_COLORS}:uu=38;5;069" # Me
export EXA_COLORS="${EXA_COLORS}:un=38;5;160" # Not me

export EXA_COLORS="${EXA_COLORS}:da=38;5;241" # Date

export EXA_COLORS="${EXA_COLORS}:di=38;5;35" # Directories
export EXA_COLORS="${EXA_COLORS}:fi=38;5;252" # Files
export EXA_COLORS="${EXA_COLORS}:ex=4;38;5;141" # Executable
export EXA_COLORS="${EXA_COLORS}:ln=38;5;69" # Symlink source
export EXA_COLORS="${EXA_COLORS}:lp=38;5;69" # Symlink destination
export EXA_COLORS="${EXA_COLORS}:or=38;5;160" # Broken symlink

export EXA_COLORS="${EXA_COLORS}:pi=48;5;13" # Named pipe (unstyled)
export EXA_COLORS="${EXA_COLORS}:cd=48;5;13" # Character device (unstyled)
export EXA_COLORS="${EXA_COLORS}:so=48;5;13" # Socket (unstyled)
export EXA_COLORS="${EXA_COLORS}:bd=48;5;13" # Block device (unstyled)

export LS_COLORS="${LS_COLORS}:*.pdf=1;38;5;136" # *.pdf



