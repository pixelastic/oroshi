# Exa
#
# See https://the.exa.website/docs/colour-themes
#
# Configuring the colors used by exa (ls clone). 
# To configure the colors used for the individual files, check
# filetypes-list.zsh

EXA_COLORS=""
EXA_COLORS="${EXA_COLORS}:xx=38;5;$COLOR_GRAY_7" # Punctuation

EXA_COLORS="${EXA_COLORS}:ur=38;5;$COLOR_GRAY_7" # User read
EXA_COLORS="${EXA_COLORS}:uw=38;5;$COLOR_GRAY_7" # User write
EXA_COLORS="${EXA_COLORS}:ux=4;38;5;$COLOR_PURPLE" # User execute

EXA_COLORS="${EXA_COLORS}:gr=38;5;$COLOR_GRAY_7" # Group read
EXA_COLORS="${EXA_COLORS}:gw=38;5;$COLOR_GRAY_7" # Group write
EXA_COLORS="${EXA_COLORS}:gx=4;38;5;$COLOR_PURPLE" # Group execute

EXA_COLORS="${EXA_COLORS}:tr=38;5;$COLOR_GRAY_7" # Other read
EXA_COLORS="${EXA_COLORS}:tw=38;5;$COLOR_GRAY_7" # Other write
EXA_COLORS="${EXA_COLORS}:tx=4;38;5;$COLOR_PURPLE" # Other execute

EXA_COLORS="${EXA_COLORS}:sn=38;5;$COLOR_GRAY_6" # Size
EXA_COLORS="${EXA_COLORS}:sb=38;5;$COLOR_GRAY_7" # Size unit

EXA_COLORS="${EXA_COLORS}:uu=38;5;$COLOR_BLUE_8" # Me
EXA_COLORS="${EXA_COLORS}:un=38;5;$COLOR_RED_5" # Not me

EXA_COLORS="${EXA_COLORS}:da=38;5;$COLOR_GRAY_7" # Date

EXA_COLORS="${EXA_COLORS}:di=38;5;$COLOR_GREEN" # Directories
EXA_COLORS="${EXA_COLORS}:ex=4;38;5;$COLOR_PURPLE_5" # Executable
export EXA_COLORS

# EXA_COLORS="${EXA_COLORS}:fi=38;5;252" # Files
# EXA_COLORS="${EXA_COLORS}:ln=38;5;69" # Symlink source
# EXA_COLORS="${EXA_COLORS}:lp=38;5;69" # Symlink destination
# EXA_COLORS="${EXA_COLORS}:or=38;5;160" # Broken symlink
# EXA_COLORS="${EXA_COLORS}:pi=48;5;13" # Named pipe (unstyled)
# EXA_COLORS="${EXA_COLORS}:cd=48;5;13" # Character device (unstyled)
# EXA_COLORS="${EXA_COLORS}:so=48;5;13" # Socket (unstyled)
# EXA_COLORS="${EXA_COLORS}:bd=48;5;13" # Block device (unstyled)
