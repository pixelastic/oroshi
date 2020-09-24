local DEBUG_STARTTIME=$(($(date +%s%N)/1000000))

# # Coloring manpages
# export LESS_TERMCAP_md=$'\E[38;5;68m'               # Titles
# export LESS_TERMCAP_us=$'\E[04;38;5;209m'           # Values
# export LESS_TERMCAP_so=$'\E[01;48;5;67;38;5;233m'   # Info box
# export LESS_TERMCAP_mb=$'\E[01;48;5;133;38;5;160m'  # ????
# export LESS_TERMCAP_me=$'\E[0m'
# export LESS_TERMCAP_se=$'\E[0m'
# export LESS_TERMCAP_ue=$'\E[0m'

# Coloring bat
# export BAT_THEME="TwoDark"


# Coloring exa
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

# export EXA_COLORS="${EXA_COLORS}:di=38;5;35" # Directories
# export EXA_COLORS="${EXA_COLORS}:fi=38;5;252" # Files
export EXA_COLORS="${EXA_COLORS}:ex=4;38;5;$COLOR[purple5]" # Executable
# export EXA_COLORS="${EXA_COLORS}:ln=38;5;69" # Symlink source
# export EXA_COLORS="${EXA_COLORS}:lp=38;5;69" # Symlink destination
# export EXA_COLORS="${EXA_COLORS}:or=38;5;160" # Broken symlink

# export EXA_COLORS="${EXA_COLORS}:pi=48;5;13" # Named pipe (unstyled)
# export EXA_COLORS="${EXA_COLORS}:cd=48;5;13" # Character device (unstyled)
# export EXA_COLORS="${EXA_COLORS}:so=48;5;13" # Socket (unstyled)
# export EXA_COLORS="${EXA_COLORS}:bd=48;5;13" # Block device (unstyled)

# # Archives (bold green)
# export LS_COLORS="${LS_COLORS}:*.cbr=1;38;5;28" 
# export LS_COLORS="${LS_COLORS}:*.cbz=1;38;5;28" 
# export LS_COLORS="${LS_COLORS}:*.deb=1;38;5;28" 
# export LS_COLORS="${LS_COLORS}:*.gz=1;38;5;28" 
# export LS_COLORS="${LS_COLORS}:*.rar=1;38;5;28" 
# export LS_COLORS="${LS_COLORS}:*.tar.gz=1;38;5;28" 
# export LS_COLORS="${LS_COLORS}:*.tgz=1;38;5;28" 
# export LS_COLORS="${LS_COLORS}:*.zip=1;38;5;28" 
# # Large images (bold yellow)
# export LS_COLORS="${LS_COLORS}:*.pdf=1;38;5;136" 
# # Fonts (dark yellow)
# export LS_COLORS="${LS_COLORS}:*.eot=38;5;136" 
# export LS_COLORS="${LS_COLORS}:*.otf=38;5;136" 
# export LS_COLORS="${LS_COLORS}:*.ttf=38;5;136" 
# export LS_COLORS="${LS_COLORS}:*.woff2=38;5;136" 
# export LS_COLORS="${LS_COLORS}:*.woff=38;5;136" 
#
# Folders: Green
# Archives: Bold green
# Documents (PDF, word): bold yellow
# Text: orange
# Executable: underline orange
# Useless: Gray
# Images: blue
# Videos: Bold blue
# # Images (yellow)
# export LS_COLORS="${LS_COLORS}:*.svg=38;5;184" 
# Text files (dark orange)
export LS_COLORS="${LS_COLORS}:*.md=38;5;$COLOR[yellow7]"
export LS_COLORS="${LS_COLORS}:*.txt=38;5;$COLOR[yellow7]"
export LS_COLORS="${LS_COLORS}:LICENSE=38;5;$COLOR[yellow7]"
export LS_COLORS="${LS_COLORS}:MAINTAINERS=38;5;$COLOR[yellow7]"
# Scripts (purple)
export LS_COLORS="${LS_COLORS}:Gemfile=38;5;$COLOR[purple5]"
export LS_COLORS="${LS_COLORS}:Guardfile*=38;5;$COLOR[purple5]"
export LS_COLORS="${LS_COLORS}:Rakefile=38;5;$COLOR[purple5]"
export LS_COLORS="${LS_COLORS}:*.cfg=38;5;$COLOR[purple5]"
export LS_COLORS="${LS_COLORS}:*.conf=38;5;$COLOR[purple5]"
export LS_COLORS="${LS_COLORS}:*.css=38;5;$COLOR[purple5]"
export LS_COLORS="${LS_COLORS}:*.gemspec=38;5;$COLOR[purple5]"
export LS_COLORS="${LS_COLORS}:*.html=38;5;$COLOR[purple5]"
export LS_COLORS="${LS_COLORS}:*.ini=38;5;$COLOR[purple5]"
export LS_COLORS="${LS_COLORS}:*.json=38;5;$COLOR[purple5]"
export LS_COLORS="${LS_COLORS}:*.js=38;5;$COLOR[purple5]"
export LS_COLORS="${LS_COLORS}:*.pug=38;5;$COLOR[purple5]"
export LS_COLORS="${LS_COLORS}:*.py=38;5;$COLOR[purple5]"
export LS_COLORS="${LS_COLORS}:*.rb=38;5;$COLOR[purple5]"
export LS_COLORS="${LS_COLORS}:*.sass=38;5;$COLOR[purple5]"
export LS_COLORS="${LS_COLORS}:*.scss=38;5;$COLOR[purple5]"
export LS_COLORS="${LS_COLORS}:*.sh=38;5;$COLOR[purple5]"
export LS_COLORS="${LS_COLORS}:*.svg=38;5;$COLOR[purple5]"
export LS_COLORS="${LS_COLORS}:*.theme=38;5;$COLOR[purple5]"
export LS_COLORS="${LS_COLORS}:*.toml=38;5;$COLOR[purple5]"
export LS_COLORS="${LS_COLORS}:*.xml=38;5;$COLOR[purple5]"
export LS_COLORS="${LS_COLORS}:*.yaml=38;5;$COLOR[purple5]"
export LS_COLORS="${LS_COLORS}:*.yml=38;5;$COLOR[purple5]"
export LS_COLORS="${LS_COLORS}:*.zsh=38;5;$COLOR[purple5]"
# Images (blue)
export LS_COLORS="${LS_COLORS}:*.jpg=38;5;$COLOR[blue]"
export LS_COLORS="${LS_COLORS}:*.gif=38;5;$COLOR[blue]"
export LS_COLORS="${LS_COLORS}:*.png=38;5;$COLOR[blue]"
export LS_COLORS="${LS_COLORS}:*.ico=38;5;$COLOR[blue]"
# Videos (bold blue)
export LS_COLORS="${LS_COLORS}:*.mpg=1;38;5;$COLOR[blue]"
export LS_COLORS="${LS_COLORS}:*.mp4=1;38;5;$COLOR[blue]"
export LS_COLORS="${LS_COLORS}:*.avi=1;38;5;$COLOR[blue]"
export LS_COLORS="${LS_COLORS}:*.mkv=1;38;5;$COLOR[blue]"
# Less important files
export LS_COLORS="${LS_COLORS}:*.js.map=38;5;$COLOR[gray7]"
export LS_COLORS="${LS_COLORS}:*.lock=38;5;$COLOR[gray7]"
export LS_COLORS="${LS_COLORS}:*.log=38;5;$COLOR[gray7]"
export LS_COLORS="${LS_COLORS}:*.min.css=38;5;$COLOR[gray7]"
export LS_COLORS="${LS_COLORS}:*.min.js=38;5;$COLOR[gray7]"
export LS_COLORS="${LS_COLORS}:*.part=38;5;$COLOR[gray7]"
export LS_COLORS="${LS_COLORS}:.envrc=38;5;$COLOR[gray7]"
export LS_COLORS="${LS_COLORS}:_algolia_api_key=38;5;$COLOR[gray7]"
# Lock files
export LS_COLORS="${LS_COLORS}:*.pid=38;5;$COLOR[yellow]"
export LS_COLORS="${LS_COLORS}:*.lock=38;5;$COLOR[yellow3]"
# Lock files

local DEBUG_ENDTIME=$(($(date +%s%N)/1000000))
[[ $ZSH_DEBUG == 1 ]] && echo "[debug]: ${0:t}: $(($DEBUG_ENDTIME - $DEBUG_STARTTIME))ms"
