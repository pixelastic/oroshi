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
alias gf='rg -l --color=never'
alias c='bat'
alias cat='bat'
alias cmus='TERM=screen-256color cmus'
alias cp='cp -rvi'
alias cpv='copy-verbose'
alias diff='git diff --no-index --word-diff=color --word-diff-regex=.'
alias grep='grep -i --color=auto'
alias h='help'
alias ls="l"
alias la="l --all"
alias l@="l --long --extended"
alias la@="ls --all --extended --long"
alias l@a="la@"
alias man='batman'
alias mkdir="mkdir -p"
alias mv='mv -vi'
alias mvv='move-verbose'
alias ping="prettyping --nolegend"
alias rmdir='better-rmdir'
alias rm='trash-put'
alias rmz='trash-restore'
alias scp='scp -r '
alias serve='live-server'
disable -r time # ZSH overrides the time method
alias time='time -p '
alias tree='l --tree'
alias treed='l --tree --only-dirs'
alias treew='watch -c ''l --tree'''
alias wtree=treew
alias watch='watch -c '
alias wr='watch-and-reload'
alias w='which'
# }}}
# Global aliases {{{
alias -g .....='../../../..'
alias -g ....='../../..'
alias -g ...='../..'
alias -g F="| fzf"
alias -g G="| grep"
alias -g H="| head"
alias -g L="| less -R"
alias -g X="| xargs"
alias -g NE='2>/dev/null'
alias -g NO='1>/dev/null'
alias -g S="| sort -V"
alias -g T="| tail"
alias -g V="&& jobsdone || say 'This failed'"
# }}}
# Typos {{{
alias mc="mv"
alias sl="l"
alias s="l"
alias cta="cat"
alias spoify='spotify'
alias spotufy='spotify'
alias spotofy='spotify'
alias spot='spotify'
# }}}
# Misc {{{
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
# Journal entries
alias jrnle='jrnl --edit'
alias jrnll='jrnl -n 10'
# }}}
# Download {{{
alias pd='plowdown'
alias td='transmission-download'
alias yt='yt-dlp -o "%(title)s.%(ext)s" --prefer-free-format'
alias ytx='yt-dlp -o "%(title)s.%(ext)s" -x --audio-format mp3'
alias gfv="get_flash_videos -y"
# }}}
# GUI apps {{{
alias datagrip='gui datagrip'
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
alias dc="docker-compose"
# Images
alias di?="di-exists"
alias dip='docker-image-prune'
alias dimv='docker-image-rename'
# Containers
alias dcr='docker-container-run'
alias dce='docker-container-run --exec-mode'
alias dr='docker run'
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
alias of="fc-cache -f -v"
alias oh="~/.oroshi/scripts/deploy/hosts"
alias os="~/.oroshi/scripts/deploy/ssh"
alias oz="colors-refresh && source ~/.zshrc"
alias vk="v ~/.oroshi/config/kitty/kitty.conf"
# }}}
# Trash {{{
alias tr?='trash-exists'
alias trl='trash-list'
alias trr='trash-restore'
# }}}
# Tmux {{{
alias tmsRa='tmux kill-session -a'
alias tmsR='tmux kill-session -t'
alias tmsaF='tmux a -dt'
alias tmsa='tmux attach -t'
alias tmsc='tmux new -s'
alias tmsl='tmux list-sessions'
# }}}
 
# Versioning {{{
require 'aliases-git.zsh'
# }}}
# Vim {{{
alias v='nvim -p'
alias vo="v ~/.oroshi/config/nvim/colors/oroshi.vim"
alias va="v ~/.oroshi/config/zsh/aliases.zsh"
alias ve='v ~/.oroshi/config/nvim/init.vim'
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
alias yrtm='yr test:manual'
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
alias yrpn='yr post:new'
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
alias yuF='yu --force'
alias ypc='depcheck . --ignore-dirs=dist,tmp,build --specials=eslint,webpack,babel --ignores=husky,jest'
# }}}
# Ruby {{{
alias be='bundle exec'
alias ba='bundle add'
alias bi="bundle-install"
alias bu="bundle-update"
alias gR="gem-uninstall"
alias gi="gem-install"
alias gs="gem search"
alias gu="gem-update"
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
alias nvs='nvm use'
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
# Python {{{
alias pi="pip install"
alias pR="pip uninstall"
alias pil='pip list'
# }}}
# Appraisal {{{
alias ai='appraisal install'
# }}}
# Rake {{{
alias rr='rake release'
alias rt='rake test'
alias rw='rake watch'
alias rl='rake lint'
alias rta='$(git root)/scripts/test_all_ruby_versions'
# }}}
# Transmission {{{
alias ta="transmission-remote -a "
alias tl="transmission-remote -l"
# }}}
# mark / jump {{{
# Thanks to https://jeroenjanssens.com/navigate/
export MARKPATH=$HOME/.marks
alias m='mark'
alias mR='unmark'
alias ml="ls $MARKPATH"
function j { 
  cd -P "${MARKPATH}/$1" 2>/dev/null || echo "No such mark: $1"
}
