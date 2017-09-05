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
alias ag='better-rg'
alias rg='better-rg'
alias cp='cp -rv'
alias cmus='TERM=screen-256color cmus'
alias diff='colordiff'
alias grep='grep -i --color=auto'
alias la="ls -a"
alias ls="ls -vhlp --color=always --group-directories-first"
alias l="ls"
alias mkdir="mkdir -p"
alias mv='mv -vi'
alias rmdir='better-rmdir'
alias cat='better-cat'
alias rm='trash-put'
alias RM='\rm -rf'
alias scp='scp -r '
alias serve='live-server'
alias treed='tree -dN'
alias tree='tree -aNC -I ".hg|.git"'
alias watch='watch -c '
alias wr='watch-and-reload'
alias w='which'
function f() { find . -type f -iname "*$1*" }
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
# }}}
# Typos {{{
alias mc="mv"
alias sl="ls"
alias s="ls"
alias cta="cat"
alias trash-restore="restore-trash"
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
# watch tree
alias wt='watch -c ''tree -aNC -I ".hg\|.git"'''
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
alias dob='docker-build'
alias docR='docker-container-remove'
alias docl='docker-container-list -a'
alias doiR='docker-image-remove'
alias doil='docker-image-list'
alias doim='docker-image-list'
alias dops='docker-container-list'
alias dord='docker run -d -P' # Run daemon, expose ports
alias dori='docker run -t -i' # Run interactive
alias dor='docker run'
alias dostai='docker-container-start -i'
alias dosta='docker-container-start'
alias dosto='docker-container-stop'
function dobash() { docker exec -it "$1" /bin/bash }
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
alias om="mouse-speed 2"
alias or="redshift -x && redshift -o"
alias os="~/.oroshi/scripts/deploy/ssh"
alias ox="~/.oroshi/scripts/deploy/xmodmap"
alias oz="source ~/.zshrc"
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

# Npm (Deprecated) {{{
alias nig='npm install --global'
alias nisd='yarn add --dev'
alias nis='yarn add'
alias ni='yarn'
alias nrb='node-root-run yarn run build'
alias nrc='node-root-run yarn run consolidate'
alias nrd='node-root-run yarn run deploy'
alias nrl='node-root-run yarn run lint'
alias nrp='node-root-run yarn run push'
alias nrr='npm run release'
alias nrs='node-root-run yarn run serve'
alias nrtw='node-root-run yarn run test:watch'
alias nrt='node-root-run yarn run test'
# }}}
# Yarn {{{
alias yR='node-root-run yarn remove'
alias yad='node-root-run yarn add --dev -- '
alias yag='yarn global add -- '
alias ya='node-root-run yarn add -- '
alias ygR='yarn global remove'
alias yga='yarn global add -- '
alias yi='node-root-run yarn'
alias yrb='node-root-run yarn run build'
alias yrc='node-root-run yarn run consolidate'
alias yrd='node-root-run yarn run deploy'
alias yrlf='node-root-run yarn run lint:fix'
alias yrl='node-root-run yarn run lint'
alias yrp='node-root-run yarn run push'
alias yrr='node-root-run yarn run release'
alias yrs='node-root-run yarn run serve'
alias yrtw='node-root-run yarn run test:watch'
alias yrt='node-root-run yarn run test'
# }}}
# Nvm {{{
alias nvu='nvm use'
alias nvud='nvm use default'
alias nvl='nvm list'
alias nvd='nvm version default'
alias nvc='nvm current'
# }}}
# Bundler {{{
alias be='bundle exec'
alias bi='bundle install'
# }}}
# Pip {{{
alias pi='pip install --user'
# }}}
# Appraisal {{{
alias ai='appraisal install'
# }}}
# Gem {{{
alias gi="gem install"
alias gs="gem-search"
alias gu="gem update"
alias gR="gem uninstall"
# }}}
# Rake {{{
alias ri='rake install'
alias rr='rake release'
alias rvbma='rake version:bump:major'
alias rvbmi='rake version:bump:minor'
alias rvbp='rake version:bump:patch'
# }}}
# Jekyll {{{
alias jap='jekyll algolia push -t'
alias jb='jekyll build -t'
alias jsw='jekyll serve --watch --baseurl "" -t'
# }}}
# mark / jump {{{
# Thanks to
# : http://jeroenjanssens.com/2013/08/16/quickly-navigate-your-filesystem-from-the-command-line.html
export MARKPATH=$HOME/.marks
function j { 
  cd -P "$MARKPATH/$1" 2>/dev/null || echo "No such mark: $1"
}
function m { 
  mkdir -p "$MARKPATH"; ln -s "$(pwd)" "$MARKPATH/$1"
}
function um { 
  rm -i "$MARKPATH/$1"
}
# }}}

