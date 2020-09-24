# Exa
#
# See https://the.exa.website/docs/colour-themes
#
# Configuring the colors used by exa (ls clone). To configure the colors used
# for the individual files, check the ls theme

export EXA_COLORS=""
export EXA_COLORS="${EXA_COLORS}:xx=38;5;$COLOR[gray7]" # Punctuation

export EXA_COLORS="${EXA_COLORS}:ur=38;5;$COLOR[gray7]" # User read
export EXA_COLORS="${EXA_COLORS}:uw=38;5;$COLOR[gray7]" # User write
export EXA_COLORS="${EXA_COLORS}:ux=4;38;5;$COLOR[purple]" # User execute

export EXA_COLORS="${EXA_COLORS}:gr=38;5;$COLOR[gray7]" # Group read
export EXA_COLORS="${EXA_COLORS}:gw=38;5;$COLOR[gray7]" # Group write
export EXA_COLORS="${EXA_COLORS}:gx=4;38;5;$COLOR[purple]" # Group execute

export EXA_COLORS="${EXA_COLORS}:tr=38;5;$COLOR[gray7]" # Other read
export EXA_COLORS="${EXA_COLORS}:tw=38;5;$COLOR[gray7]" # Other write
export EXA_COLORS="${EXA_COLORS}:tx=4;38;5;$COLOR[purple]" # Other execute

export EXA_COLORS="${EXA_COLORS}:sn=38;5;$COLOR[gray6]" # Size
export EXA_COLORS="${EXA_COLORS}:sb=38;5;$COLOR[gray7]" # Size unit

export EXA_COLORS="${EXA_COLORS}:uu=38;5;$COLOR[blue8]" # Me
export EXA_COLORS="${EXA_COLORS}:un=38;5;$COLOR[red5]" # Not me

export EXA_COLORS="${EXA_COLORS}:da=38;5;$COLOR[gray7]" # Date

export EXA_COLORS="${EXA_COLORS}:di=38;5;$COLOR[green]" # Directories
export EXA_COLORS="${EXA_COLORS}:ex=4;38;5;$COLOR[purple5]" # Executable

# export EXA_COLORS="${EXA_COLORS}:fi=38;5;252" # Files
# export EXA_COLORS="${EXA_COLORS}:ln=38;5;69" # Symlink source
# export EXA_COLORS="${EXA_COLORS}:lp=38;5;69" # Symlink destination
# export EXA_COLORS="${EXA_COLORS}:or=38;5;160" # Broken symlink
# export EXA_COLORS="${EXA_COLORS}:pi=48;5;13" # Named pipe (unstyled)
# export EXA_COLORS="${EXA_COLORS}:cd=48;5;13" # Character device (unstyled)
# export EXA_COLORS="${EXA_COLORS}:so=48;5;13" # Socket (unstyled)
# export EXA_COLORS="${EXA_COLORS}:bd=48;5;13" # Block device (unstyled)
