# Gvm
# Currently disabling this, as I don't much go
# TODO: Make this smarter, like the lazyloading we use for JavaScript
return

# Switch go version
local gvmPath=~/.gvm/scripts/gvm
[[ -r $gvmPath ]] || return

source $gvmPath
