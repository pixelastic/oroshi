# Note: We follow the convention of putting manually installed binaries in
# /usr/local/bin. OS installed binaries goes to /usr/bin.
#
# Small scripts that are more of a wrapper for convenient calls will go to
# ~/.oroshi/scripts/bin and ~/.oroshi/scripts/bin/local/{hostname}.
#
# Those last two directories will be added to the path in interactive mode.
#
# Note: If we want to override default commands, we should write an alias that
# point to a custom script for overwriting the command. As alias are not passed
# on to scripts, we avoid overwriting basic commands that some externals tools
# will rely on.
#
# Note: Calling sudo will NOT use any aliases defined, but will use files in
# custom paths.
alias sudo='sudo '

# Custom paths {{{
path=(
	$path
	~/.oroshi/scripts/bin
	~/.oroshi/private/scripts/bin
	~/.oroshi/scripts/bin/local/$(hostname)
	~/.oroshi/private/sripts/bin/local/$(hostname)
	~/local/bin
)
# }}}

# Basic commands {{{
# ls : colors and human readable size
alias ls="ls -vhlp --color=always --group-directories-first"
# grep : colored
alias grep='grep -i --color=auto'
# tree : colored, show hidden files but hides git/hg. Display non-ASCII chars
alias tree='tree -aNC -I ".hg|.git"'
# watch : colored
alias watch='watch -c '
# diff : colored
alias diff='colordiff'

# Create subdirectories recursively
alias mkdir="mkdir -p"
# rm : use system trash
alias rm='trash-put'
# rmdir : use system trash
alias rmdir='better-rmdir'
# cp : recursive and verbose
alias cp='cp -rv'
# mv : verbose and interactive if destination exists
alias mv='mv -vi'
# }}}
# Global aliases {{{
alias -g NE='2>/dev/null'
alias -g NO='1>/dev/null'
alias -g T="| tail"
alias -g H="| head"
alias -g G="| grep"
alias -g L="| less -R"
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
# }}}
# Typos {{{
alias sl="ls"
alias mc="mv"
# }}}
# Misc {{{
# cp and mv using rsync and preserving attributes, and accross fat32 drives
function rcp() { rsync -rahP --modify-window=1 "$@" }
function rmv() { rsync -rahP --modify-window=1 --prune-empty-dirs --remove-sent-files "$@" }
compdef _cp rcp rmv
# Scrollable colors
alias spectrum='spectrum L'
# ls with hidden files
alias la="ls -a"
# Tree that only display directories
alias treed='tree -dN'
# Opening nautilus
alias n="gui nautilus"
# Find a file
function f() { find . -iname "*$1*" }
# Reload test files
alias rr='reload-tests'
# Mount /dev/sd* to ~/local/mnt/sd*
function mountsd() {
echo "Mounting /dev/sd$1 to ~/local/mnt/sd$1"
sudo mount -t vfat /dev/sd$1 ~/local/mnt/sd$1
cd ~/local/mnt/sd$1
}
# plowdown
alias pd='plowdown'
# Download files from transmission
alias td='transmission-download'
# Youtube downloader
alias yt='youtube-dl -t --prefer-free-format'
# Flash video download
alias gfv="get_flash_videos"
# watch tree
alias wt='watch -c ''tree -aNC -I ".hg\|.git"'''
# Prefix a date to a file
alias prd='prefix-date'
# }}}
# GUI apps {{{
alias chrome="gui chromium-browser"
alias disk-utility='gui palimpsest'
alias ebook-viewer='gui ebook-viewer'
alias eog='gui eog'
alias evince="gui evince"
alias gftp='gui gftp'
alias lowriter='gui lowriter'
alias poedit='gui poedit'
alias vlc='gui vlc'
# }}}

# Apt-get {{{
alias apt-get='apt-fast'
alias agi='sudo apt-fast install'
alias agu='sudo apt-fast -u install'
alias agr='sudo apt-fast remove'
alias ags='sudo apt-cache search'
# }}}
# Ebook {{{
alias ec='ebook-convert'
alias ecc='ebook-cover-change'
alias ecd='ebook-cover-download'
alias em='ebook-meta'
alias emu='ebook-metadata-update'
alias ev='ebook-viewer'
# }}}
# Directories {{{
alias cd-='cd -'
alias cdo='cd ~/.oroshi/'
alias cdl='cd ~/local/'
alias cde='cd ~/local/etc/'
alias cdw='cd ~/local/var/www/'
alias cdt='cd ~/local/tmp/'
alias cds='cd ~/local/tmp/scripts/'
alias cdsov='cd ~/local/tmp/sov/'
alias cdrop="cd ~/Dropbox/"
alias cdpaper="cd ~/Dropbox/tim/paperwork/"
alias cdbooks='cd ~/Documents/books'
alias cdemu='cd ~/Documents/emulation'
alias cdm='cd ~/Documents/movies/'
alias cdp='cd ~/Documents/pictures'
alias cdrp='cd ~/Documents/roleplay/'
alias cdscenar='cd ~/Documents/roleplay/scenarios/'
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
alias oz="source ~/.zshrc"
alias oa="source ~/.oroshi/config/zsh/aliases.zsh"
alias oc="~/.oroshi/scripts/deploy/dircolors && source ~/.zshrc"
alias ox="~/.oroshi/scripts/deploy/xmodmap"
alias oh="~/.oroshi/scripts/deploy/hosts"
# }}}
# Versioning {{{
# Note: Context-sensitive aliases are defined in ./aliases-{git|hg|none}.zsh
alias vdc='create-repo'
alias vdt='get-version-system'
alias vdcl='git clone --recursive'
# }}}
# Vim {{{
alias v='vim -p'
alias va="vim ~/.oroshi/config/zsh/aliases.zsh"
alias vf="vim ~/.oroshi/config/zsh/filetypes.db.zsh"
alias ve='vim ~/.oroshi/config/vim/vimrc'
# }}}
# Synchronize stuff {{{
alias michel-extract='camera-extract /media/MICHEL/'
alias galaxy-extract='camera-extract /media/F101-14E2/DCIM'
alias dingoo-sync='~/Documents/emulation/devices/dingoo/tools/dingoo-sync /media/dingoo'
alias ebook-sync='ebook-sync ~/Documents/books /media/galaxy/books'
alias sansa-sync-music="music-sync /media/jukebox/music sansa-sd"
alias sansa-sync-misc="music-sync /media/jukebox/misc sansa"
alias sansa-sync-nature="music-sync /media/jukebox/nature sansa"
alias sansa-sync-podcasts="music-sync /media/jukebox/podcasts sansa"
alias sansa-sync-soundtracks="music-sync /media/jukebox/soundtracks sansa-sd"
# }}}
# Tweet {{{
alias tweet="t update"
alias timeline="t stream timeline"
alias tsearch="t search all"
# }}}
# Web {{{
alias flushdns="/etc/init.d/dns-clean start"
alias speedtest='wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test500.zip'
# }}}

# Private aliases  {{{
local privateAlias=~/.oroshi/private/config/zsh/local/$(hostname).zsh
if [[ -r $privateAlias ]]; then
	source $privateAlias
fi
# }}}
# NVM {{{
local nvmScript=~/local/etc/nvm/nvm.sh
if [[ -r $nvmScript ]]; then
  source $nvmScript
fi
# }}}
# RVM {{{
local rvmScript=~/.rvm/scripts/rvm
if [[ -r $rvmScript ]]; then
	path=($path	$HOME/.rvm/bin)
  source $rvmScript
fi
# }}}

