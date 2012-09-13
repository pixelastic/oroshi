# aliases-none.zsh
# This file is only loaded when not in a repo. It will nullify every alias
# defined in aliases-git.zsh or aliases-hg.zsh

# Only load the alias list once as the file will be source multiple times
if [[ ${#versionAliases[*]} = 0 ]]; then
	# local versionAliases
	versionAliases=(
		vbb vbc vbl vbm vbr vbrr vbs vbsm
		vcc vcca vcd vce vcl vcr
		vfa vfaa vfc vfm vfr vfrm vfu
		vrR vra vrdw 
		vrR 
		vtc vtl vtr vts vtt
		vdd vdr vdR vdra vdl vdu
	)
fi

# Rewrite all aliases
for alias in $versionAliases; do
	eval "alias $alias='echo ""$alias error: You are not in a repo""'"
done
