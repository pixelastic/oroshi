# Note: Calling sudo will NOT use any aliases defined, but will use files in
# custom paths.
alias sudo='sudo -E'

# Options {{{
# Allow moving to a directory without typing cd
setopt AUTO_CD
# Allow special chars (^ or ?) in aliases, otherwise they are treated as regexp
# markers
unsetopt NOMATCH
# }}}

# Basic commands {{{
alias rg='better-rg'
alias ag='rg'
alias cat='better-cat'
alias cmus='TERM=screen-256color cmus'
alias cp='cp -rv'
alias diff='git diff --no-index --word-diff=color --word-diff-regex=.'
alias grep='grep -i --color=auto'
alias ls="exa --long --group-directories-first --git --time-style=long-iso --color=always"
alias la="ls --all"
alias l@="ls -l@"
alias la@="ls --all -l@"
alias mkdir="mkdir -p"
alias mv='mv -vi'
alias ping="prettyping --nolegend"
alias rmdir='better-rmdir'
alias rm='trash-put'
alias scp='scp -r '
alias serve='live-server'
disable -r time # ZSH overrides the time method
alias time='time -p '
alias treed='\tree -dN'
alias tree='ls -T'
alias treew='watch -c ''tree -aNC -I ".hg\|.git"'''
alias wtree=treew
alias watch='watch -c '
alias wr='watch-and-reload'
alias w='which'
alias f="fd"
alias fh="fd --hidden"
# }}}
# Global aliases {{{
alias -g .....='../../../..'
alias -g ....='../../..'
alias -g ...='../..'
alias -g G="| grep"
alias -g H="| head"
alias -g L="| less -R"
alias -g NE='2>/dev/null'
alias -g NO='1>/dev/null'
alias -g S="| sort -V"
alias -g T="| tail"
alias -g V="&& jobsdone || say 'This failed'"
# }}}
# Typos {{{
alias mc="mv"
alias sl="ls"
alias s="ls"
alias cta="cat"
alias trash-restore="restore-trash"
alias spoify='spotify'
alias spotufy='spotify'
alias spot='spotify'
# }}}
# Misc {{{
# cp and mv using rsync and preserving attributes, and accross fat32 drives
# Note: We use functions and not alias so we can specify a custom completion
# function (the same as scp, in _scp) without having to overwrite the whole
# `rsync` completion command
function rcp { rsync -vrahP --modify-window=1 "$@" }
function rmv { 
  rsync -vrahP --modify-window=1 --prune-empty-dirs --remove-sent-files "$@"
}
_scp () { local service=scp; _ssh "$@" }
compdef _scp rcp rmv

# Scrollable colors
alias spectrum='spectrum L'
# Prefix a date to a file
alias prd='prefix-date'
# Fix previous command
alias fuck='$(thefuck $(fc -ln -1))'
# Find all extensions
alias extension-list="find . -type f | awk -F'.' '{print \$NF}' | sort| uniq -c | sort -g"
# Always run guard in clear mode
alias guard='guard --clear'
# Check connectivity
alias p8='ping 8.8.8.8'
# Edit the journal entries
alias jrnle='jrnl --edit'
# }}}
# Download {{{
alias pd='plowdown'
alias td='transmission-download'
alias yt='youtube-dl -o "%(title)s.%(ext)s" --prefer-free-format --max-filesize 700m'
alias ytx='youtube-dl -o "%(title)s.%(ext)s" -x --audio-format mp3'
alias gfv="get_flash_videos -y"
# }}}
# GUI apps {{{
alias ccsm='gui ccsm'
alias charles='gui charles'
alias disk-utility='gui palimpsest'
alias ebook-viewer='gui ebook-viewer'
alias eog='gui eog'
alias evince="gui evince"
alias gftp='gui gftp'
alias hipchat="gui hipchat"
alias lowriter='gui lowriter'
alias n="gui nautilus"
alias pinta='gui pinta'
alias poedit='gui poedit'
alias skype='gui skype'
alias steam='gui steam'
alias virtualbox='gui virtualbox'
alias vlc='gui vlc'
alias xmind='gui XMind'
# }}}

# Apt-get {{{
alias agR='sudo apt-get remove -y'
alias agi='apt-get-install'
alias ags='apt-get-search'
alias agu='sudo apt-get install -y --only-upgrade'
alias agv='apt-get-version'
alias ag?='apt-get-exists'
# }}}
# Ebook {{{
alias ec='ebook-convert'
alias emu='ebook-metadata-update'
alias em='ebook-meta'
alias ev='ebook-viewer'
alias pdf2jpg='pdf2img'
alias pdf2png='pdf2img -png'
# }}}
# Docker {{{
# Images
alias dib='docker-image-build'
alias db='docker build'
alias dip='docker-image-prune'
alias diR='docker-image-remove'
alias dil='docker-image-list'
alias dimv='docker-image-rename'
# Containers
alias dcr='docker-container-run'
alias dce='docker-container-run --exec-mode'
alias dr='docker run'
alias dcl='docker-container-list'
alias dcR='docker-container-remove'
alias dcRa='docker-container-remove --all'
# }}}
# Directories {{{
alias cde='cd ~/local/etc/'
alias cdl='cd ~/local/'
alias cdo='cd ~/.oroshi/'
alias cdd="cd ~/Dropbox/tim/"
alias cdp="cd ~/Dropbox/tim/paperwork/"
alias cdi="cd ~/Dropbox/tim/ids/"
alias cdsov='cd ~/local/tmp/sov/'
alias cds='cd ~/local/src/'
alias cdt='cd ~/local/tmp/'
alias cdw='cd ~/local/www/'
alias cd-='cd -'
# }}}
# Dingoo {{{
alias udingoo='umount /media/dingoo'
alias cdingoo='cd /media/dingoo'
# }}}
# Music {{{
alias mmu='music-metadata-update'
alias mktl='generate-tracklist'
alias mm="music-mark"
# }}}
# Freebox {{{
alias fbx='sudo mount -t cifs //mafreebox.freebox.fr/Disque\ dur/ /home/tim/local/mnt/freebox -o _netdev,guest,uid=1000,iocharset=utf8,file_mode=0777,dir_mode=0777'
alias ufbx='sudo umount /home/tim/local/mnt/freebox'
alias cdfbx='cd /home/tim/local/mnt/freebox'
# }}}
# Dropbox {{{
alias dbsta='dropbox start'
alias dbsto='dropbox stop'
alias dbst='dropbox status'
# }}}
# Nginx {{{
alias ngst="sudo systemctl status nginx"
alias ngsta="sudo systemctl start nginx"
alias ngsto="sudo systemctl stop nginx"
alias ngrst="sudo systemctl restart nginx"
alias ngrld="sudo systemctl reload nginx"
# }}}
#	Oroshi {{{
alias oa="~/.oroshi/scripts/deploy/autostart"
alias oc="~/.oroshi/scripts/deploy/dircolors && source ~/.zshrc"
alias of="~/.oroshi/scripts/deploy/fstab"
alias oh="~/.oroshi/scripts/deploy/hosts"
alias or="redshift -x && redshift -o"
alias os="~/.oroshi/scripts/deploy/ssh"
alias oz="source ~/.zshrc"
function ok() {
  # Reload keybindings
  ~/.oroshi/scripts/deploy/xmodmap # Custom keys
  ~/.oroshi/config/ubuntu/18.04/keybindings.sh # App bindings
  ~/.oroshi/scripts/deploy/xbindkeys # Screen and sound
}
# }}}
# Trash {{{
alias tr?='trash-exists'
alias trl='trash-list'
alias trr='trash-restore'
# }}}
# Tmux {{{
alias tsRa='tmux kill-session -a'
alias tsR='tmux kill-session -t'
alias tsaF='tmux a -dt'
alias tsa='tmux attach -t'
alias tsc='tmux new -s'
alias tsl='tmux list-sessions'
# }}}
 
# Versioning {{{
source ~/.oroshi/config/zsh/aliases-git.zsh
# }}}
# Vim {{{
alias v='vim -p'
alias va="vim ~/.oroshi/config/zsh/aliases.zsh"
alias vf="vim ~/.oroshi/config/zsh/filetypes.db.zsh"
alias ve='vim ~/.oroshi/config/vim/vimrc'
alias vw='vim-which'
# }}}
# DocSearch {{{
export DOCSEARCH_DIR=~/local/www/algolia/docsearch/docsearch-scraper
alias ds="$DOCSEARCH_DIR/docsearch "
alias dsb="ds bootstrap "
function dsr() {
  cd $DOCSEARCH_DIR; 
  ./docsearch docker:run ../docsearch-configs/configs/$1.json
}
alias dss="cd $DOCSEARCH_DIR/playground && serve"
function dsrp() {
  cd $DOCSEARCH_DIR; 
  APPLICATION_ID=$APPLICATION_ID_PROD API_KEY=$API_KEY_PROD ./docsearch run ../docsearch-configs/configs/$1.json
}
alias dsd="cd $DOCSEARCH_DIR; ./docsearch deploy "
# }}}
# Tweet {{{
alias tweet="t update"
alias timeline="t stream timeline"
alias tsearch="t search all"
# }}}
# Web {{{
alias csslint="csslint \$(cat ~/.csslintrc) "
alias cssmin="cleancss"
alias flushdns="/etc/init.d/dns-clean start"
alias htmlmin="html-minifier --remove-comments --collapse-whitespace --remove-attribute-quotes --remove-redundant-attributes --use-short-doctype"
alias jsmin="uglifyjs"
alias recess="recess --config ~/.recessrc"
alias speedtest='wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test500.zip'
# }}}
# Yarn {{{
alias yR='yarn remove'
alias yad='yarn add --dev -- '
alias yadf='yarn add --dev -W -- '
alias yagR='yarn global remove'
alias yag='yarn global add -- '
alias ya='yarn add -- '
alias yaf='yarn add -W -- '
alias ygR='yarn global remove'
alias yga='yarn global add -- '
alias y='yarn'
alias yF='yarn --force'
alias yi='yarn init'
alias yrb='yr build'
alias yrbw='yr build:watch'
alias yrbp='yr build:prod'
alias yrc='yr consolidate'
alias yrdb='yr docs:build'
alias yrdbp='yr docs:build:prod'
alias yrds='yr docs:serve'
alias yrdd='yr docs:deploy'
alias yrlb='yr lambda:build'
alias yrlbw='yr lambda:build:watch'
alias yrls='yr lambda:serve'
alias yrtv='yr test:visual'
alias yrtva='yr test:visual:approve'
alias yrd='yr deploy'
alias yrlf='yr lint:fix'
alias yrljs='yr lint:js'
alias yrljson='yr lint:json'
alias yrlc='yr lint:css'
alias yrlm='yr lint:md'
alias yrlmf='yr lint:md:fix'
alias yrlh='yr lint:html'
alias yrl='yr lint'
alias yrpb='yr playground:build'
alias yrps='yr playground:serve'
alias yrp='yr push'
alias yrr='vbpl && yr release'
alias yrrp='yrr patch'
alias yrrmi='yrr minor'
alias yrrma='yrr major'
alias yrs='yr serve'
alias yrw='yr watch'
alias yl?='yarn-has-links'
alias yw='yarn why'
alias ysd='emma -D'
alias ys='emma'
alias yug='yarn global upgrade'
alias ypc='depcheck . --ignore-dirs=dist,tmp,build --specials=eslint,webpack,babel --ignores=husky,jest'
# }}}
# Ruby {{{
alias be='bundle exec'
alias ba='bundle add'
alias bi="bundle install"
alias bu="bundle update"
alias gR="gem uninstall"
alias gi="gem install"
alias gs="gem search"
alias gu="gem update"
# }}}
# Jekyll {{{
alias js='jekyll serve --trace'
alias jb="jekyll build --trace"
alias ja="jekyll algolia --trace"
alias jan="jekyll algolia --dry-run --trace"
alias jav="jekyll algolia --verbose --trace"
alias javn="jekyll algolia --verbose --dry-run --trace"
alias janv="jekyll algolia --verbose --dry-run --trace"
# }}}
# Nvm {{{
alias nvu='nvm use'
alias nvud='nvm use default'
alias nvl='nvm list'
alias nvd='nvm version default'
alias nvc='nvm current'
# }}}
# Java {{{
alias jl="update-java-alternatives --list"
alias jv8="sudo update-java-alternatives -s java-1.8.0-openjdk-amd64"
alias jv11="sudo update-java-alternatives -s java-11-oracle"
alias jv12="sudo update-java-alternatives -s java-12-oracle"
# }}}
# Kubernetes {{{
local coriolisAliases=~/.oroshi/scripts/bin/coriolis/aliases.zsh
if [[ -r $coriolisAliases ]]; then
  source $coriolisAliases
fi
# }}}
# Gcloud {{{
function g() {
  pyv2
  gcloud "$@"
  pyvs
}
# }}}
# Python {{{
# Pyenv allow us to switch globally to python 2 or 3
alias pyvl='pyenv versions'
alias pyvi='pyenv install'
alias pyvR='pyenv uninstall'
alias pyv2='pyenv activate 2'
alias pyv3='pyenv activate 3'
alias pyvs='pyenv deactivate'
# When installing things through pip, we install them in the python
# 3 environment by default
alias pR='pip uninstall'
alias pi='pip-install-version 3'
alias pi2='pip-install-version 2'
alias pi3='pip-install-version 3'
alias pil='pip list'
alias piu='pip install --upgrade pip'
# When in a project, we can use pipenv to jump into this project env
alias pis="pipenv shell"
alias pir="pipenv run"
alias pii="pipenv install"
alias piid="pipenv install --dev"
alias piR="pipenv uninstall"
# }}}
# Appraisal {{{
alias ai='appraisal install'
# }}}
# Rake {{{
alias rr='rake release'
alias rt='rake test'
alias rtw='rake test:watch'
alias rl='rake lint'
alias rta='$(git root)/scripts/test_all_ruby_versions'
# }}}
# mark / jump {{{
# Thanks to
# : http://jeroenjanssens.com/2013/08/16/quickly-navigate-your-filesystem-from-the-command-line.html
export MARKPATH=$HOME/.marks
alias m='mark'
alias mR='unmark'
function j { 
  cd -P "$MARKPATH/$1" 2>/dev/null || echo "No such mark: $1"
}
function ml { 
  ls $MARKPATH
}
