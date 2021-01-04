# ls
#
# Configure the colors used by ls (and exa) to display the various files and
# directories

LS_COLORS=""
LS_COLORS="${LS_COLORS}:di=38;5;$COLOR[green]" # Directory
LS_COLORS="${LS_COLORS}:ln=34;4;$COLOR[blue6]" # Symlink
LS_COLORS="${LS_COLORS}:ex=4;38;5;$COLOR[purple5]" # Executable

# Text files {{{
LS_COLORS="${LS_COLORS}:*.md=38;5;$COLOR[orange5]"
LS_COLORS="${LS_COLORS}:*.txt=38;5;$COLOR[orange5]"
LS_COLORS="${LS_COLORS}:*LICENSE=38;5;$COLOR[orange5]"
LS_COLORS="${LS_COLORS}:*MAINTAINERS=38;5;$COLOR[orange5]"
LS_COLORS="${LS_COLORS}:*CODEOWNERS=38;5;$COLOR[orange5]"
# }}}
# Scripts (purple) {{{
LS_COLORS="${LS_COLORS}:*Dockerfile*=38;5;$COLOR[purple5]"
LS_COLORS="${LS_COLORS}:*Gemfile=38;5;$COLOR[purple5]"
LS_COLORS="${LS_COLORS}:*Guardfile*=38;5;$COLOR[purple5]"
LS_COLORS="${LS_COLORS}:*Rakefile=38;5;$COLOR[purple5]"
LS_COLORS="${LS_COLORS}:*Vagrantfile=38;5;$COLOR[purple5]"
LS_COLORS="${LS_COLORS}:*.cfg=38;5;$COLOR[purple5]"
LS_COLORS="${LS_COLORS}:*.conf=38;5;$COLOR[purple5]"
LS_COLORS="${LS_COLORS}:*.css=38;5;$COLOR[purple5]"
LS_COLORS="${LS_COLORS}:*.gemspec=38;5;$COLOR[purple5]"
LS_COLORS="${LS_COLORS}:*.html=38;5;$COLOR[purple5]"
LS_COLORS="${LS_COLORS}:*.ini=38;5;$COLOR[purple5]"
LS_COLORS="${LS_COLORS}:*.json=38;5;$COLOR[purple5]"
LS_COLORS="${LS_COLORS}:*.js=38;5;$COLOR[purple5]"
LS_COLORS="${LS_COLORS}:*.pug=38;5;$COLOR[purple5]"
LS_COLORS="${LS_COLORS}:*.py=38;5;$COLOR[purple5]"
LS_COLORS="${LS_COLORS}:*.rb=38;5;$COLOR[purple5]"
LS_COLORS="${LS_COLORS}:*.ru=38;5;$COLOR[purple5]"
LS_COLORS="${LS_COLORS}:*.sass=38;5;$COLOR[purple5]"
LS_COLORS="${LS_COLORS}:*.scss=38;5;$COLOR[purple5]"
LS_COLORS="${LS_COLORS}:*.sh=38;5;$COLOR[purple5]"
LS_COLORS="${LS_COLORS}:*.svg=38;5;$COLOR[purple5]"
LS_COLORS="${LS_COLORS}:*.theme=38;5;$COLOR[purple5]"
LS_COLORS="${LS_COLORS}:*.toml=38;5;$COLOR[purple5]"
LS_COLORS="${LS_COLORS}:*.ts=38;5;$COLOR[purple5]"
LS_COLORS="${LS_COLORS}:*.vim=38;5;$COLOR[purple5]"
LS_COLORS="${LS_COLORS}:*.xml=38;5;$COLOR[purple5]"
LS_COLORS="${LS_COLORS}:*.yaml=38;5;$COLOR[purple5]"
LS_COLORS="${LS_COLORS}:*.yml=38;5;$COLOR[purple5]"
LS_COLORS="${LS_COLORS}:*.zsh=38;5;$COLOR[purple5]"
# }}}
# Hidden config files {{{
LS_COLORS="${LS_COLORS}:*.*rc=38;5;$COLOR[purple7]"
LS_COLORS="${LS_COLORS}:*.*config=38;5;$COLOR[purple7]"
LS_COLORS="${LS_COLORS}:*.*-version=38;5;$COLOR[purple7]"
LS_COLORS="${LS_COLORS}:*.*ignore=38;5;$COLOR[purple7]"
LS_COLORS="${LS_COLORS}:*.=38;5;$COLOR[purple7]"
# }}}
# Images {{{
LS_COLORS="${LS_COLORS}:*.jpg=38;5;$COLOR[yellow5]"
LS_COLORS="${LS_COLORS}:*.gif=38;5;$COLOR[yellow5]"
LS_COLORS="${LS_COLORS}:*.png=38;5;$COLOR[yellow5]"
LS_COLORS="${LS_COLORS}:*.ico=38;5;$COLOR[yellow5]"
# }}}
# Audio files {{{
LS_COLORS="${LS_COLORS}:*.mp3=38;5;$COLOR[blue4]"
LS_COLORS="${LS_COLORS}:*.wav=38;5;$COLOR[blue4]"
# }}}
# Videos {{{
LS_COLORS="${LS_COLORS}:*.mpg=1;38;5;$COLOR[blue]"
LS_COLORS="${LS_COLORS}:*.mp4=1;38;5;$COLOR[blue]"
LS_COLORS="${LS_COLORS}:*.avi=1;38;5;$COLOR[blue]"
LS_COLORS="${LS_COLORS}:*.mkv=1;38;5;$COLOR[blue]"
# }}}
# Archives {{{
LS_COLORS="${LS_COLORS}:*.cbr=1;38;5;$COLOR[green]" 
LS_COLORS="${LS_COLORS}:*.cbz=1;38;5;$COLOR[green]" 
LS_COLORS="${LS_COLORS}:*.deb=1;38;5;$COLOR[green]" 
LS_COLORS="${LS_COLORS}:*.gz=1;38;5;$COLOR[green]" 
LS_COLORS="${LS_COLORS}:*.rar=1;38;5;$COLOR[green7]" 
LS_COLORS="${LS_COLORS}:*.tar.gz=1;38;5;$COLOR[green]" 
LS_COLORS="${LS_COLORS}:*.tgz=1;38;5;$COLOR[green]" 
LS_COLORS="${LS_COLORS}:*.zip=1;38;5;$COLOR[green]" 
# }}}
# Documents {{{
LS_COLORS="${LS_COLORS}:*.pdf=1;38;5;$COLOR[yellow7]"
LS_COLORS="${LS_COLORS}:*.epub=38;5;$COLOR[yellow7]"
# }}}
# Less important files {{{
LS_COLORS="${LS_COLORS}:*.js.map=38;5;$COLOR[gray7]"
LS_COLORS="${LS_COLORS}:*.lock=38;5;$COLOR[gray7]"
LS_COLORS="${LS_COLORS}:*.lock=38;5;$COLOR[gray7]"
LS_COLORS="${LS_COLORS}:*.log=38;5;$COLOR[gray7]"
LS_COLORS="${LS_COLORS}:*.min.css=38;5;$COLOR[gray7]"
LS_COLORS="${LS_COLORS}:*.min.js=38;5;$COLOR[gray7]"
LS_COLORS="${LS_COLORS}:*.part=38;5;$COLOR[gray7]"
LS_COLORS="${LS_COLORS}:*.pid=38;5;$COLOR[gray7]"
LS_COLORS="${LS_COLORS}:*_algolia_api_key=38;5;$COLOR[gray7]"
# }}}
export LS_COLORS

# # Large images (bold yellow)
# LS_COLORS="${LS_COLORS}:*.pdf=1;38;5;136" 
# # Fonts (dark yellow)
# LS_COLORS="${LS_COLORS}:*.eot=38;5;136" 
# LS_COLORS="${LS_COLORS}:*.otf=38;5;136" 
# LS_COLORS="${LS_COLORS}:*.ttf=38;5;136" 
# LS_COLORS="${LS_COLORS}:*.woff2=38;5;136" 
# LS_COLORS="${LS_COLORS}:*.woff=38;5;136" 

