# FILETYPES DATABASE
# We define here, in ZSH syntax, an array defining each type of files, with the
# command to open it, the color to display it and the matching set of
# extensions.
#
# Doing so, we can simply source this file in a ZSH script to get the relevant
# information whenever we need to handle custom filetypes.
#
# Color code are defined in the format {style};{foreground};{background}
# With {style} being one of : {{{
#   00=none
#   01=bold
#   04=underscore
#   05=blink
#   07=reverse
#   08=concealed
# }}}
# And {foreground} being one of : {{{
#   30=black
#   31=red
#   32=green
#   33=yellow
#   34=blue
#   35=magenta
#   36=cyan (orange)
#   37=white 
# }}}
# And {background} being one of : {{{
#   40=black
#   41=red
#   42=green
#   43=yellow
#   44=blue
#   45=magenta
#   46=cyan (orange)
#   47=white 
# }}}

typeset -Ag O_FILETYPES
O_FILETYPES=(
	android     "ls:00;31:apk"
	archive     "extract:01;32:7z,bz2,cbr,cbz,gz,r00,r01,r02,r03,r04,r05,r06,r07,r08,r09,rar,tar,gz,tgz,zip"
	audio       "gui vlc:00;34:mp3,wav,ogg,m4a"
	config      "vim:00;33:conf,config,db,ini"
	ebook       "ebook-viewer:01;33:epub,mobi"
	executable  "wine:00;31:exe,pyc,so"
	flash       "gui chromium-browser:01;34:swf"
	font        "ls:01;33:eot,otf,svg,ttf,woff"
	image       "gui eog:00;33:bmp,gif,ico,jpeg,jpg,png,tga,tiff,swf"
	pdf         "gui evince:01;33:pdf"
	psd         "ls:01;33:psd"
	python      "python3:00;35:py"
	script      "vim:00;35:ahk,appcache,bat,c,ctp,css,dat,erb,htm,html,js,json,kml,less,lua,manifest,php,rb,scss,sql,vim,xml,yml,zsh,zsh-theme"
	sheet       "gui localc:01;33:ods,xls"
	subtitle    "vim:00;36:ass,srt,sub"
	tmp         "vim:00;30:bak,kpf,orig,out,swp,tmp"
	txt         "vim:00;36:log,markdown,md,mdown,mkd,mkdown,mo,po,template,text,txt"
	txt-full    "writer:01;33:doc,docx,odt"
	video       "gui vlc:01;34:3gp,avi,flv,m4v,mpg,mpeg,mkv,mp4,webm"
)
