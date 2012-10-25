# aliases-none.zsh
# This file is only loaded when not in a repo. It will nullify every alias
# defined in aliases-git.zsh or aliases-hg.zsh

# Only load the alias list once as the file will be source multiple times
if [[ ${#versionAliases[*]} = 0 ]]; then
	# local versionAliases
	versionAliases=(
		vbR vbb vbc vbl vbm vbmm vbr vbrr vbs vbsm
		vcc vcca vcd vce vcl vcla vcr
		vdR vdd vddl vdl vdr vdra vdu
		vfR vfa vfaa vfc vfm vfr vfu
		vrR vrc vrdw vrl vrps vrpl vrr vrout vrin
		vsR vsc vse vsl vsr
		vsbi vbsa vbsu
		vtc vtl vtr vts vtt
	)
fi

# Rewrite all aliases
for alias in $versionAliases; do
	eval "alias $alias='echo ""$alias error: Unknown version system call""'"
done
