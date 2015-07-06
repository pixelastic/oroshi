# Note: If we want to override default commands, we should write an alias that
# point to a custom script for overwriting the command. As alias are not passed
# on to scripts, we avoid overwriting basic commands that some externals tools
# will rely on.
#
# Note: Calling sudo will NOT use any aliases defined, but will use files in
# custom paths.
alias sudo='sudo -E'

# Custom paths {{{
path=(
	~/.oroshi/scripts/bin
	~/.oroshi/private/scripts/bin
	~/.oroshi/scripts/bin/local/$(hostname)
	~/.oroshi/private/scripts/bin/local/$(hostname)
	$path
	~/local/bin
  ~/.local/bin
)
export CHROME_BIN=`which chromium-browser`
# }}}

# Options {{{
# Allow moving to a directory without typing cd
setopt AUTO_CD
# Allow special chars (^ or ?) in aliases, otherwise they are treated as regexp
# markers
unsetopt NOMATCH
# }}}

# Basic commands {{{
alias ag='ag --context=2 --smart-case --pager="less -R"'
alias cp='cp -rv'
alias diff='colordiff'
alias grep='grep -i --color=auto'
alias ls="ls -vhlp --color=always --group-directories-first"
alias mkdir="mkdir -p"
alias mv='mv -vi'
alias rm='trash-put'
alias rmdir='better-rmdir'
alias scp='scp -r '
alias tree='tree -aNC -I ".hg|.git"'
alias watch='watch -c '
alias serve='http-server .'
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
alias ms="ls"
alias sl="ls"
alias trash-restore="restore-trash"
# }}}
# Misc {{{
# cp and mv using rsync and preserving attributes, and accross fat32 drives
alias rcp="rsync -vrahP --modify-window=1"
alias rmv="rsync -vrahP --modify-window=1 --prune-empty-dirs --remove-sent-files"
# Scrollable colors
alias spectrum='spectrum L'
# ls with hidden files
alias la="ls -a"
# Tree that only display directories
alias treed='tree -dN'
# Find a file
function f() { find . -type f -iname "*$1*" }
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
# }}}
# Download {{{
alias pd='plowdown'
alias td='transmission-download'
alias yt='youtube-dl -t --prefer-free-format --max-filesize 700m'
alias gfv="get_flash_videos -y"
# }}}
# GUI apps {{{
alias ccsm='gui ccsm'
alias charles='gui charles'
alias chrome="gui chromium-browser"
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
alias steam='gui steam'
alias virtualbox='gui virtualbox'
alias vlc='gui vlc'
alias xmind='gui XMind'
# }}}

# Apt-get {{{
alias agi='apt-get-install'
alias ag?='apt-get-exists'
alias ags='apt-get-search'
alias agv='apt-get-version'
alias agR='sudo apt-get remove -y'
alias agu='sudo apt-get install -y --only-upgrade'
# }}}
# Ebook {{{
alias ec='ebook-convert'
alias ecc='ebook-cover-change'
alias ecd='ebook-cover-download'
alias em='ebook-meta'
alias emu='ebook-metadata-update'
alias ev='ebook-viewer'
function epub2mobi() {
  ebook-convert $1 .mobi
}
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
alias rg='replaygain'
alias mfs="mark-for-sync"
function mfs-sansa() { mark-for-sync $* sansa }
function mfs-sansa-sd() { mark-for-sync $* sansa-sd }
# }}}
# Freebox {{{
alias fbx='sudo mount -t cifs //mafreebox.freebox.fr/Disque\ dur/ /home/tim/local/mnt/freebox -o _netdev,guest,uid=1000,iocharset=utf8,file_mode=0777,dir_mode=0777'
alias ufbx='sudo umount /home/tim/local/mnt/freebox'
alias cdfbx='cd /home/tim/local/mnt/freebox'
# }}}
# Nginx {{{
alias ngsta="ng start"
alias ngsto="ng stop"
alias ngrst="ng restart"
alias ngpsta="ng --php start"
alias ngpsto="ng --php stop"
alias ngprst="ng --php restart"
# }}}
#	Oroshi {{{
alias oa="~/.oroshi/scripts/deploy/autostart"
alias oc="~/.oroshi/scripts/deploy/dircolors && source ~/.zshrc"
alias of="~/.oroshi/scripts/deploy/fstab"
alias oh="~/.oroshi/scripts/deploy/hosts"
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
alias tsc='tmux new -s'
alias tsa='tmux attach -t'
alias tsl='tmux list-sessions'
alias tsR='tmux kill-session -t'
# }}}
 
# Versioning {{{
source './aliases-git.zsh'
# }}}
# Vim {{{
alias v='vim -p'
alias va="vim ~/.oroshi/config/zsh/aliases.zsh"
alias vf="vim ~/.oroshi/config/zsh/filetypes.db.zsh"
alias ve='vim ~/.oroshi/config/vim/vimrc'
function vw() { vim `which $1` }
# }}}
# Serenity {{{
alias cdse="cd ~/local/mnt/serenity/"
alias cdsevid="cd ~/local/mnt/serenity/video/"
alias cdsemus="cd ~/local/mnt/serenity/music/"
# }}}
# Tweet {{{
alias tweet="t update"
alias timeline="t stream timeline"
alias tsearch="t search all"
# }}}
# Web {{{
alias csslint="csslint \$(cat ~/.csslintrc) "
alias recess="recess --config ~/.recessrc"
alias flushdns="/etc/init.d/dns-clean start"
alias speedtest='wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test500.zip'
alias cssmin="cleancss"
alias jsmin="uglifyjs"
alias htmlmin="html-minifier --remove-comments --collapse-whitespace --remove-attribute-quotes --remove-redundant-attributes --use-short-doctype"
function header() {
  curl -s -D - $1 -o /dev/null
}
# }}}

# Npm {{{
alias nRg='npm uninstall -g'
alias nig='npm install --global'
alias nisd='npm install --save-dev'
alias nis='npm install --save'
alias ni='npm install'
# }}}
# Grunt {{{
alias gt='grunt test'
alias gj='grunt jshint'
alias gbi='grunt bowerInstall'
# }}}
# Bower {{{
alias bs='bower search'
alias bi='bower install'
alias bis='bower install --save'
alias bisd='bower install --save-dev'
# }}}
# Gem {{{
alias gi="gem install"
alias gs="gem search"
alias gu="gem update"
alias gR="gem uninstall"
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
function mm {
    ls -l "$MARKPATH" | sed 's/  / /g' | cut -d' ' -f9- | sed 's/ -/\t-/g' && echo
}
# }}}

# NVM {{{
local nvmScript=~/local/etc/nvm/nvm.sh
if [[ -r $nvmScript ]]; then
  source $nvmScript
	nvm use 0.10 &>/dev/null
fi
# }}}
# GVM {{{
local gvmScript=~/.gvm/scripts/gvm
if [[ -r $gvmScript ]]; then
  source $gvmScript
fi
# }}}
# RVM {{{
local rvmScript=~/.rvm/scripts/rvm
if [[ -r $rvmScript ]]; then
	path=($HOME/.rvm/bin $path)
  source $rvmScript
  rvm use ruby-2.2.1 &>/dev/null
fi
# }}}
