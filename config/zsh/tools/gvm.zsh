# Gvm
# Currently disabling this, as I don't much go
return
# Switch go version
local gvmPath=~/.gvm/scripts/gvm
[[ -r $gvmPath ]] || return

source $gvmPath
