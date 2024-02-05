# Exa
#
# See https://the.exa.website/docs/colour-themes

EXA_COLORS=""
EXA_COLORS="${EXA_COLORS}:xx=38;5;$COLOR_ALIAS_UI" # Punctuation

EXA_COLORS="${EXA_COLORS}:fi=38;5;$COLOR_GRAY_WHITE" # Default file color

EXA_COLORS="${EXA_COLORS}:ur=38;5;$COLOR_GRAY_7"   # User read
EXA_COLORS="${EXA_COLORS}:uw=38;5;$COLOR_GRAY_7"   # User write
EXA_COLORS="${EXA_COLORS}:ux=4;38;5;$COLOR_PURPLE" # User execute

EXA_COLORS="${EXA_COLORS}:gr=38;5;$COLOR_GRAY_7"   # Group read
EXA_COLORS="${EXA_COLORS}:gw=38;5;$COLOR_GRAY_7"   # Group write
EXA_COLORS="${EXA_COLORS}:gx=4;38;5;$COLOR_PURPLE" # Group execute

EXA_COLORS="${EXA_COLORS}:tr=38;5;$COLOR_GRAY_7"   # Other read
EXA_COLORS="${EXA_COLORS}:tw=38;5;$COLOR_GRAY_7"   # Other write
EXA_COLORS="${EXA_COLORS}:tx=4;38;5;$COLOR_PURPLE" # Other execute

EXA_COLORS="${EXA_COLORS}:sn=38;5;$COLOR_NEUTRAL"       # Size
EXA_COLORS="${EXA_COLORS}:sb=38;5;$COLOR_NEUTRAL_LIGHT" # Size unit

EXA_COLORS="${EXA_COLORS}:uu=38;5;$COLOR_BLACK" # Me
EXA_COLORS="${EXA_COLORS}:un=38;5;$COLOR_RED_5" # Not me

EXA_COLORS="${EXA_COLORS}:da=38;5;$COLOR_ALIAS_DATE" # Date

EXA_COLORS="${EXA_COLORS}:ga=38;5;$COLOR_ALIAS_GIT_ADDED"     # File added
EXA_COLORS="${EXA_COLORS}:gm=38;5;$COLOR_ALIAS_GIT_MODIFIED"  # File modified
EXA_COLORS="${EXA_COLORS}:gd=38;5;$COLOR_ALIAS_GIT_REMOVED"   # File Deleted
EXA_COLORS="${EXA_COLORS}:gv=38;5;$COLOR_ALIAS_GIT_MODIFIED"  # File renamed
EXA_COLORS="${EXA_COLORS}:gt=38;5;$COLOR_ALIAS_VARIABLE_TYPE" # File type changed

EXA_COLORS="${EXA_COLORS}:di=38;5;$COLOR_GREEN"      # Directories
EXA_COLORS="${EXA_COLORS}:ex=4;38;5;$COLOR_VIOLET_4" # Executable

# EXA_COLORS="${EXA_COLORS}:ln=38;5;69"  # Symlink source
# EXA_COLORS="${EXA_COLORS}:lp=38;5;69"  # Symlink destination
# EXA_COLORS="${EXA_COLORS}:or=38;5;160" # Broken symlink
# EXA_COLORS="${EXA_COLORS}:pi=48;5;13"  # Named pipe (unstyled)
# EXA_COLORS="${EXA_COLORS}:cd=48;5;13"  # Character device (unstyled)
# EXA_COLORS="${EXA_COLORS}:so=48;5;13"  # Socket (unstyled)
# EXA_COLORS="${EXA_COLORS}:bd=48;5;13"  # Block device (unstyled)


# Enhance EXA_COLORS by looping through all FILETYPES_***_color
# TODO: Need to color .nvmrc, .eslintignore, and all files starting with
# a dot, without an extension
for extension in ${=FILETYPES_INDEX}; do
  # Those are nested zsh modifiers:
  # - ${AAA:-BBB} reads AAA variables, and if empty sets BBB as the value
  # - Here, we set AAA as empty, so it jumps rights to BBB
  # - Which is converted into the string FILETYPES_XXX_YYY
  # - ${(P}CCC} reads the value of CCC and uses it as the variable name
  local pattern=${(P)${:-FILETYPE_${extension}_PATTERN}}
  local color=${(P)${:-FILETYPE_${extension}_COLOR}}
  local bold=${(P)${:-FILETYPE_${extension}_BOLD}}

  EXA_COLORS="${EXA_COLORS}:${pattern}=${bold};38;5;$color"
done


export EXA_COLORS
