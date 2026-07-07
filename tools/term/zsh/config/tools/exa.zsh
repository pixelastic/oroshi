# Exa
#
# See https://the.exa.website/docs/colour-themes
function exa-configure-colors() {
  colors-load-definitions

  EXA_COLORS=""
  EXA_COLORS="${EXA_COLORS}:xx=38;5;$COLORS[ui]" # Punctuation

  EXA_COLORS="${EXA_COLORS}:fi=38;5;$COLORS[gray-white]" # Default file color

  EXA_COLORS="${EXA_COLORS}:ur=38;5;$COLORS[gray-7]"       # User read
  EXA_COLORS="${EXA_COLORS}:uw=38;5;$COLORS[gray-7]"       # User write
  EXA_COLORS="${EXA_COLORS}:ux=4;38;5;$COLORS[executable]" # User execute

  EXA_COLORS="${EXA_COLORS}:gr=38;5;$COLORS[gray-7]"       # Group read
  EXA_COLORS="${EXA_COLORS}:gw=38;5;$COLORS[gray-7]"       # Group write
  EXA_COLORS="${EXA_COLORS}:gx=4;38;5;$COLORS[executable]" # Group execute

  EXA_COLORS="${EXA_COLORS}:tr=38;5;$COLORS[gray-7]"       # Other read
  EXA_COLORS="${EXA_COLORS}:tw=38;5;$COLORS[gray-7]"       # Other write
  EXA_COLORS="${EXA_COLORS}:tx=4;38;5;$COLORS[executable]" # Other execute

  EXA_COLORS="${EXA_COLORS}:sn=38;5;$COLORS[neutral]"     # Size
  EXA_COLORS="${EXA_COLORS}:sb=38;5;$COLORS[punctuation]" # Size unit

  EXA_COLORS="${EXA_COLORS}:uu=38;5;$COLORS[black]" # Me
  EXA_COLORS="${EXA_COLORS}:un=38;5;$COLORS[red-5]" # Not me

  EXA_COLORS="${EXA_COLORS}:da=38;5;$COLORS[date]" # Date

  EXA_COLORS="${EXA_COLORS}:ga=38;5;$COLORS[git-added]"     # File added
  EXA_COLORS="${EXA_COLORS}:gm=38;5;$COLORS[git-modified]"  # File modified
  EXA_COLORS="${EXA_COLORS}:gd=38;5;$COLORS[git-removed]"   # File Deleted
  EXA_COLORS="${EXA_COLORS}:gv=38;5;$COLORS[git-modified]"  # File renamed
  EXA_COLORS="${EXA_COLORS}:gt=38;5;$COLORS[variable-type]" # File type changed

  EXA_COLORS="${EXA_COLORS}:di=38;5;$COLORS[directory]"  # Directories
  EXA_COLORS="${EXA_COLORS}:ex=38;5;$COLORS[executable]" # Executable

  EXA_COLORS="${EXA_COLORS}:ln=38;5;$COLORS[unknown]" # Symlink source
  EXA_COLORS="${EXA_COLORS}:lp=38;5;$COLORS[unknown]" # Symlink destination
  EXA_COLORS="${EXA_COLORS}:or=38;5;$COLORS[unknown]" # Broken symlink
  EXA_COLORS="${EXA_COLORS}:pi=48;5;$COLORS[unknown]" # Named pipe (unstyled)
  EXA_COLORS="${EXA_COLORS}:cd=48;5;$COLORS[unknown]" # Character device (unstyled)
  EXA_COLORS="${EXA_COLORS}:so=48;5;$COLORS[unknown]" # Socket (unstyled)
  EXA_COLORS="${EXA_COLORS}:bd=48;5;$COLORS[unknown]" # Block device (unstyled)

  export EXA_COLORS
}
exa-configure-colors
unfunction exa-configure-colors
